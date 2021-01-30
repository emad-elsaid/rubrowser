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
          @circular = false
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

        def circular?
          @circular
        end

        def set_circular
          @circular = true
        end

        def ==(other)
          namespace == other.namespace
        end

        def <=>(other)
          to_s <=> other.to_s
        end

        def to_s
          namespace.join('::')
        end
      end
    end
  end
end
