require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

FILE_SIZE_LIMIT = 2 * 1024 * 1024

vertices = Set.new
edges = Set.new

def parse_block(node)
  return unless node.is_a?(Parser::AST::Node)

  case node.type
  when :module
    parse_module(node)
  when :class
    parse_class(node)
  else
    node.children.each { |n| parse_block(n) }
  end
end

def parse_module(node)
  name = const_to_array(node.children.first)
  puts "MODULE #{name}"
  node.children[1..-1].each { |n| parse_block(n) }
end

def parse_class(node)
  name = const_to_array(node.children.first)
  body = node.children[1..-1]
  puts "CLASS #{name}"
  body.each { |n| parse_block(n) }
end

def const_to_array(node)
  return [] unless node.is_a?(Parser::AST::Node) && node.type == :const
  const_to_array(node.children.first) + [node.children.last]
end

def parse_file(file)
  if !File.symlink?(file) && File.file?(file) && File.size(file) <= FILE_SIZE_LIMIT
    file_handle = File.open(file)
    code = file_handle.read
    file_handle.close
    ast = Parser::CurrentRuby.parse(code)
    parse_block ast
  elsif File.directory?(file)
    files = Dir.glob(File.join(file, '**', '*.rb'))
    Parallel.each(files) do |file_path|
      parse_file(file_path)
    end
  end
end

ARGV.each do |file|
  parse_file(file)
end
