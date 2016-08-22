require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


class Tree
  attr_reader :value, :children

  def initialize(value)
    @value = value
    @children = Set.new
  end

  def add_child(child_name_path = [])
    return if child_name_path.empty?
    child = get_or_create_child(child_name_path[0])
    children.add(child)
    child.add_child(child_name_path[1..-1])
  end

  def get_or_create_child(child_name)
    children.find { |child| child_name == child.value } || Tree.new(child_name)
  end

  def eq?(other)
    other.value == value
  end
end

class FileParser
  FILE_SIZE_LIMIT = 2 * 1024 * 1024
  attr_reader :file, :definitions

  def initialize(file)
    @file = file
    @definitions = Set.new
    parse
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
end

class DirectoryParser
  attr_reader :directory

  def initialize(directory)
    @directory = directory
    @parsers = []
    parse
  end

  def definitions
    parsers.map(&:definitions) || []
  end

  private

  attr_accessor :parsers

  def parse
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

parsers = ARGV.map do |file|
  if File.file?(file)
    FileParser.new(file)
  elsif File.directory?(file)
    DirectoryParser.new(file)
  end
end

names = parsers.map(&:definitions).reduce(:+)
constants_tree = Tree.new(nil)
names.each { |name| constants_tree.add_child(name) }

require 'yaml'
puts constants_tree.to_yaml
