require 'sinatra/base'
require 'data'
require 'json'

module Rubrowser
  class Server < Sinatra::Base
    get '/' do
      data = Rubrowser::Data.instance
      haml :index,
           locals: {
             constants: data.constants,
             occurences: data.occurences
           }
    end

    def self.start
      Rubrowser::Data.instance.parse
      Thread.new do
        run! host: 'localhost',
             port: 9000,
             root: File.expand_path('../../', __FILE__)
      end.join
    end
  end
end
