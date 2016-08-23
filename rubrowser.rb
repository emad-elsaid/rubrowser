$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler/setup'
Bundler.require(:default)

require 'parser/factory'
require 'parser/file'
require 'parser/directory'
require 'tree'

puts 'Reading files...'
parsers = ARGV.map do |file|
  Parser::Factory.build(file)
end

count = parsers.map(&:count).reduce(:+)
puts "#{count} Files were found."

puts 'Parsing files...'
parsers.each(&:parse)

puts 'Getting definitions...'
definitions = parsers.map(&:definitions).reduce(:+).uniq
puts "#{definitions.count} definitions were found."

puts 'Converting to a tree...'
constants_tree = Tree.new(nil)
definitions.each { |definition| constants_tree.add_child(definition) }

require 'yaml'
puts constants_tree.to_h.to_yaml
