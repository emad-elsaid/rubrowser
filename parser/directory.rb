require 'parser/file'
require 'parser/factory'

module Parser
  class Directory
    attr_reader :directory

    def initialize(directory)
      @directory = directory
      @parsers = []
      read
    end

    def parse
      self.parsers = Parallel.map(parsers) { |parser| parser.parse }
      self
    end

    def definitions
      parsers.map(&:definitions).reduce(:+) || []
    end

    def count
      parsers.map(&:count).reduce(:+)
    end

    private

    attr_accessor :parsers

    def read
      files = Dir.glob(::File.join(directory, '**', '*.rb'))
      self.parsers = Parallel.map(files) do |file|
        Factory.build(file)
      end.compact
    end
  end
end
