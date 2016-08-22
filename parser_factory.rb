class ParserFactory
  def self.build(file)
    if File.file?(file)
      FileParser.new(file)
    elsif File.directory?(file)
      DirectoryParser.new(file)
    end
  end
end
