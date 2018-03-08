module Rubrowser
  class Trace
    def initialize(path: '')
      @path = path
    end

    def run
      trace_point.enable
    end

    private

    attr_reader :path

    def trace_point
      @trace_point ||= TracePoint.new(:call) do |tp|
        $wr.puts tp.defined_class if tp.path.start_with?(path)
      end
    end
  end
end
