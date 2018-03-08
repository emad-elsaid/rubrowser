require 'lite_cable'
require 'lite_cable/server'
require 'puma/configuration'
require 'puma/launcher'
require 'rubrowser/connection'

module Rubrowser
  class Server
    def initialize(port: 8080)
      @port = port
    end

    def run
      launcher.run
    end

    private

    attr_reader :port

    def launcher
      @launcher ||= Puma::Launcher.new(conf)
    end

    def conf
      @conf ||= Puma::Configuration.new do |user_config|
        user_config.threads(1, 1)
        user_config.workers 1
        user_config.port port
        user_config.app(rack_app)
      end
    end

    def rack_app
      @app ||= Rack::Builder.new do
        map '/' do
          use LiteCable::Server::Middleware, connection_class: Rubrowser::Connection
          run proc { |_| [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
        end
      end
    end
  end
end
