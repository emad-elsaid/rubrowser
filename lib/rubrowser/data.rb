require 'rubrowser/parser/factory'
require 'tsort'

module Rubrowser
  class Data
    attr_reader :definitions, :relations

    def initialize(files)
      @files = files
      parse
    end

    private

    def parse
      parsers.each(&:parse)

      @definitions ||= parsers.map(&:definitions).reduce(:+).to_a
      @relations ||= parsers.map(&:relations).reduce(:+).to_a

      mark_circular_dependencies
    end

    def parsers
      @_parsers ||= files.map do |file|
        Rubrowser::Parser::Factory.build(file)
      end
    end

    def mark_circular_dependencies
      components = make_components
      @definitions.each do |definition|
        if components.include?(definition.namespace.first.to_s)
          definition.set_circular
        end
      end

      @relations.each do |relation|
        relation.set_circular if circular_relation?(components, relation)
      end
    end

    def make_components
      graph = Graph.new { |h, k| h[k] = [] }

      @relations.each do |relation|
        graph[relation.caller_namespace.to_s] <<
          relation.resolve(definitions).to_s
      end

      find_coupled_components(graph)
    end

    def find_coupled_components(graph)
      graph
        .strongly_connected_components
        .select { |c| c.length > 1 }
        .flatten
        .to_set
    end

    def circular_relation?(components, relation)
      components.include?(relation.namespace.to_s) &&
        components.include?(relation.caller_namespace.to_s)
    end

    class Graph < Hash
      include TSort

      alias tsort_each_node each_key

      def tsort_each_child(node, &block)
        fetch(node) { [] }.each(&block)
      end
    end

    attr_reader :files, :parsed
    alias parsed? parsed
  end
end
