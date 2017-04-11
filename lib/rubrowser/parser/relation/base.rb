require 'rubrowser/parser/definition/base'

module Rubrowser
  module Parser
    module Relation
      class Base
        attr_reader :namespace, :caller_namespace, :file, :line

        def initialize(namespace, caller_namespace, file: nil, line: nil)
          @namespace = namespace
          @caller_namespace = caller_namespace
          @file = file
          @line = line
        end

        def namespace
          Definition::Base.new(@namespace, file: file, line: line)
        end

        def caller_namespace
          Definition::Base.new(@caller_namespace, file: file, line: line)
        end

        def resolve(definitions)
          possibilities.find do |possibility|
            definitions.any? { |definition| definition == possibility }
          end || possibilities.last
        end

        def ==(other)
          namespace == other.namespace &&
            caller_namespace == other.caller_namespace
        end

        private

        def possibilities
          return [
            Definition::Base.new(@namespace.compact, file: file, line: line)
          ] if absolute?

          possible_parent_namespaces
            .map { |possible_parent| possible_parent + @namespace }
            .push(@namespace)
            .map { |i| Definition::Base.new(i, file: file, line: line) }
        end

        def possible_parent_namespaces
          (@caller_namespace.size - 1)
            .downto(0)
            .map { |i| @caller_namespace[0..i] }
        end

        def absolute?
          @caller_namespace.empty? || @namespace.first.nil?
        end
      end
    end
  end
end
