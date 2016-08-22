class FileParser
  FILE_SIZE_LIMIT = 2 * 1024 * 1024

  attr_reader :file, :definitions

  def initialize(file)
    @file = file
    @definitions = Set.new
  end

  def parse
    if file_valid?(file)
      File.open(file) do |f|
        code = f.read
        ast = Parser::CurrentRuby.parse(code)
        self.definitions = parse_block(ast)
      end
    else
      []
    end
  end

  def file_valid?(file)
    !File.symlink?(file) && File.file?(file) && File.size(file) <= FILE_SIZE_LIMIT
  end

  def count
    1
  end

  private

  attr_writer :definitions

  def parse_block(node, parents = [])
    return [] unless node.is_a?(Parser::AST::Node)

    case node.type
    when :module
      parse_module(node, parents)
    when :class
      parse_class(node, parents)
    else
      node.children.map { |n| parse_block(n, parents) }.reduce(:+) || []
    end
  end

  def parse_module(node, parents = [])
    name = resolve_const_path(node.children.first, parents)
    node.children[1..-1].map { |n| parse_block(n, name) }.reduce(:+).push(name)
  end

  def parse_class(node, parents = [])
    name = resolve_const_path(node.children.first, parents)
    body = node.children[1..-1]
    body.map { |n| parse_block(n, name) }.reduce(:+).push(name)
  end

  def resolve_const_path(node, parents = [])
    return parents unless node.is_a?(Parser::AST::Node) && node.type == :const
    resolve_const_path(node.children.first, parents) + [node.children.last]
  end
end
