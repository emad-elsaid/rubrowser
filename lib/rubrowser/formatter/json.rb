require 'json'

module Rubrowser
  module Formatter
    class JSON
      def initialize(data)
        @data = data
      end

      def call
        {
          definitions: data.definitions.map { |d| definition_as_json(d) },
          relations: data.relations.map { |r| relation_as_json(r, data.definitions) }
        }.to_json
      end

      private

      attr_reader :data

      def definition_as_json(definition)
        {
          type: demoularize(definition.class.name),
          namespace: definition.to_s,
          file: definition.file,
          line: definition.line
        }
      end

      def relation_as_json(relation, definitions)
        {
          type: demoularize(relation.class.name),
          namespace: relation.namespace.to_s,
          resolved_namespace: relation.resolve(definitions).to_s,
          caller: relation.caller_namespace.to_s,
          file: relation.file,
          line: relation.line
        }
      end

      def demoularize(class_name)
        class_name.split('::').last || ''
      end
    end
  end
end
