require 'webrick'
require 'data'
require 'formatter/json'
require 'erb'

module Rubrowser
  class Server < WEBrick::HTTPServer
    include ERB::Util

    ROUTES = {
      '/' => :root,
      '/data.json' => :data
    }

    def self.start(options = {})
      new(options).start
    end

    def initialize(options)
      super Port: options[:port]
      @files = options[:files]

      mount_proc '/' do |req, res|
        res.body = router(req.path)
      end
    end

    private

    attr_reader :files

    def router(path)
      return file(path) if file?(path)
      return send(ROUTES[path]) if ROUTES.key?(path)
      'Route not found.'
    end

    def root
      erb :index
    end

    def data
      data = Data.new(files)
      formatter = Formatter::JSON.new(data)
      formatter.call
    end

    def file?(path)
      path = resolve_file_path("/public#{path}")
      File.file?(path)
    end

    def file(path)
      File.read(resolve_file_path("/public#{path}"))
    end

    def erb(template)
      path = resolve_file_path("/views/#{template}.erb")
      file = File.open(path).read
      ERB.new(file).result binding
    end

    def resolve_file_path(path)
      File.expand_path("../..#{path}", __FILE__)
    end
  end
end
