require 'rubrowser/parser/factory'
require 'tsort'

module Rubrowser
  class Data
    attr_reader :definitions, :relations

    def initialize(files)
      @files = files
      @parsed = false
      parse
    end

    def mark_circular_dependencies
      graph = Graph.new {|h, k| h[k] = []}

      @relations.each do |relation|
        graph[relation.caller_namespace.to_s] << relation.resolve(definitions).to_s
      end

      components = graph.strongly_connected_components
                       .select {|c| c.length > 1}
                       .flatten
                       .to_set

      @definitions.each do |definition|
        definition.set_circular if components.include?(definition.namespace.first.to_s)
      end

      @relations.each do |relation|
        relation.set_circular if components.include?(relation.namespace.to_s)
      end
    end

    private

    class Graph < Hash
      include TSort

      alias tsort_each_node each_key

      def tsort_each_child(node, &block)
        fetch(node) {[]}.each(&block)
      end
    end

    attr_reader :files, :parsed
    alias parsed? parsed

    def parse
      return if parsed?
      parsers.each(&:parse)
      @parsed = true

      @definitions ||= parsers.map(&:definitions).reduce(:+).to_a
      @relations ||= parsers.map(&:relations).reduce(:+).to_a

      mark_circular_dependencies
    end

    def parsers
      @_parsers ||= files.map do |file|
        Rubrowser::Parser::Factory.build(file)
      end
    end
  end
end
