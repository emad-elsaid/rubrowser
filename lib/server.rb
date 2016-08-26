require 'webrick'
require 'haml'
require 'data'
require 'json'

module Rubrowser
  class Server < WEBrick::HTTPServer
    def self.start(paths)
      new(paths).start
    end

    def initialize(paths)
      super Port: 9000

      @data = Rubrowser::Data.new(paths)
      @data.parse

      mount_proc '/' do |req, res|
        res.body = root(req.path)
      end

      trap('INT') { shutdown }
    end

    private

    attr_reader :data

    def root(path)
      return file(path) if file?(path)

      haml :index,
           locals: {
             constants: data.constants,
             occurences: data.occurences
           }
    end

    def file?(path)
      path = resolve_file_path("/public#{path}")
      File.file?(path)
    end

    def file(path)
      File.read(resolve_file_path("/public#{path}"))
    end

    def haml(template, options = {})
      path = resolve_file_path("/views/#{template}.haml")
      file = File.open(path).read
      locals = options.delete(:locals) || {}
      Haml::Engine.new(file, options).render(self, locals)
    end

    def resolve_file_path(path)
      File.expand_path("../..#{path}", __FILE__)
    end
  end
end
