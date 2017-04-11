require 'rubrowser/parser/file'
require 'rubrowser/parser/directory'

module Rubrowser
  module Parser
    class Factory
      def self.build(file)
        if ::File.file?(file)
          File.new(file)
        elsif ::File.directory?(file)
          Directory.new(file)
        end
      end
    end
  end
end
