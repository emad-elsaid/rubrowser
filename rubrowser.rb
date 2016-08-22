$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'file_parser'
require 'directory_parser'
require 'tree'

puts 'Reading files...'
parsers = ARGV.map do |file|
  if File.file?(file)
    FileParser.new(file)
  elsif File.directory?(file)
    DirectoryParser.new(file)
  end
end

count = parsers.map(&:count).reduce(:+)
puts "#{count} Files were found."

puts 'Parsing files...'
parsers.each(&:parse)

puts 'Getting definitions and converting to tree...'
names = parsers.map(&:definitions).reduce(:+)
constants_tree = Tree.new(nil)
names.each { |name| constants_tree.add_child(name) }

require 'yaml'
puts constants_tree.to_yaml
