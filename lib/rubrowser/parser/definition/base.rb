module Rubrowser
  module Parser
    module Definition
      class Base
        attr_reader :namespace, :file, :line, :lines

        def initialize(namespace, file: nil, line: nil, lines: 0)
          @namespace = Array(namespace)
          @file = file
          @line = line
          @lines = lines
        end

        def name
          namespace.last
        end

        def parent
          new(namespace[0...-1])
        end

        def kernel?
          namespace.empty?
        end

        def ==(other)
          namespace == other.namespace
        end

        def to_s
          namespace.join('::')
        end
      end
    end
  end
end
