$VERBOSE = nil
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler/setup'
Bundler.require(:default)

require 'parser/factory'
require 'parser/file'
require 'parser/directory'
require 'tree'
require 'yaml'

parsers = ARGV.map do |file|
  Parser::Factory.build(file)
end

parsers.each(&:parse)
tree = Tree.from_parsers(parsers)
puts tree.to_h.to_yaml
