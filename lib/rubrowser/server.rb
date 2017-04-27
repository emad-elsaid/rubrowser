require 'webrick'
require 'erb'
require 'rubrowser/data'
require 'rubrowser/formatter/json'

module Rubrowser
  class Server < WEBrick::HTTPServer
    # Accepted options are:
    # port: port number for the server
    # files: list of file paths to parse
    def self.start(options = {})
      new(options).start
    end

    private

    include ERB::Util

    ROUTES = {
      '/' => :root,
      '/data.json' => :data
    }.freeze

    attr_reader :files

    def initialize(options)
      super Port: options[:port]
      @files = options[:files]

      mount_proc '/' do |req, res|
        res.body = router(req.path)
      end
    end

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
      File.expand_path("../../..#{path}", __FILE__)
    end
  end
end
