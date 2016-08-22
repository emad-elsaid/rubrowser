require 'file_parser'
require 'parser_factory'

class DirectoryParser
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
    parsers.map(&:definitions) || []
  end

  def count
    parsers.map(&:count).reduce(:+)
  end

  private

  attr_accessor :parsers

  def read
    files = Dir.glob(File.join(directory, '**', '*.rb'))
    self.parsers = Parallel.map(files) do |file|
      ParserFactory.build(file)
    end.compact
  end
end
