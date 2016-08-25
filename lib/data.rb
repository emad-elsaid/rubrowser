require 'parser/factory'
require 'tree'
require 'd3'

module Rubrowser
  class Data
    def self.instance
      @_instance ||= new
    end

    def initialize
      @files = ARGV
      @parsed = false
    end

    def constants
      @_constants ||= d3.constants.to_a
    end

    def occurences
      @_occurences ||= d3.occurences.to_a
    end

    def parse
      return if parsed?
      parsers.each(&:parse)
      @parsed = true
    end

    private

    attr_reader :files, :parsed
    alias parsed? parsed

    def parsers
      @_parsers ||= files.map do |file|
        Rubrowser::Parser::Factory.build(file)
      end
    end

    def d3
      @_d3 ||= Rubrowser::D3.new(tree)
    end

    def tree
      parse
      @_tree ||= Rubrowser::Tree.from_parsers(parsers)
    end

  end
end
