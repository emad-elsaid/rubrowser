require 'rubrowser/trace'
require 'rubrowser/server'


module Rubrowser
  module Monitor
    module_function

    def run(path: "", port: 8080)
      $rd, $wr = IO.pipe

      if fork
        $rd.close
        Trace.new(path: path).run
      else
        $wr.close
        Server.new(port: port).run
        exit
      end
    end
  end
end
