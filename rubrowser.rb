$VERBOSE = nil
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler/setup'
Bundler.require(:default)

require 'parser/factory'
require 'parser/file'
require 'parser/directory'
require 'd3'
require 'tree'
require 'json'
parsers = ARGV.map do |file|
  Parser::Factory.build(file)
end
parsers.each(&:parse)
tree = Tree.from_parsers(parsers)
d3 = D3.new(tree)
Constants = d3.constants.to_a
Occurences = d3.occurences.to_a

class App < Sinatra::Base
  get '/' do
    haml :index, locals: { constants: Constants, occurences: Occurences }
  end
end
Thread.new { App.run! host: 'localhost', port: 3000 }.join
