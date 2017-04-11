require 'rubrowser/parser/factory'

module Rubrowser
  class Data
    def initialize(files)
      @files = files
      @parsed = false
      parse
    end

    def definitions
      @_constants ||= parsers.map(&:definitions).reduce(:+).to_a
    end

    def relations
      @_relations ||= parsers.map(&:relations).reduce(:+).to_a
    end

    private

    def parse
      return if parsed?
      parsers.each(&:parse)
      @parsed = true
    end

    attr_reader :files, :parsed
    alias parsed? parsed

    def parsers
      @_parsers ||= files.map do |file|
        Rubrowser::Parser::Factory.build(file)
      end
    end
  end
end
