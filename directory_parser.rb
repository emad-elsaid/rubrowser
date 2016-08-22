require 'file_parser'

class DirectoryParser
  attr_reader :directory

  def initialize(directory)
    @directory = directory
    @parsers = []
    read
  end

  def parse
    parsers.each(&:parse)
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
      if File.file?(file)
        FileParser.new(file)
      elsif File.directory?(file)
        DirectoryParser.new(file)
      end
    end.compact
  end
end
