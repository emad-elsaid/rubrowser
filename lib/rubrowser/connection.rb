require 'rubrowser/channel'

module Rubrowser
  class Connection < LiteCable::Connection::Base
    identified_by :id

    def connect
      @id = rand(100_000)
      self.class.initiate_reader
    end

    def self.initiate_reader
      @reader ||= Thread.new do
        $rd.each_line do |line|
          LiteCable.broadcast('classes', message: line.strip)
        end
      end
    end
  end
end
