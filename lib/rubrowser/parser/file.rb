require 'parser/current'
require 'rubrowser/parser/definition/class'
require 'rubrowser/parser/definition/module'
require 'rubrowser/parser/relation/base'
require 'rubrowser/parser/file/builder'

module Rubrowser
  module Parser
    class File
      FILE_SIZE_LIMIT = 2 * 1024 * 1024

      attr_reader :file, :definitions, :relations

      def initialize(file)
        @file = ::File.absolute_path(file)
        @definitions = []
        @relations = []
      end

      def parse
        return unless valid_file?(file)

        constants = constants_from_file

        @definitions = constants[:definitions]
        @relations = constants[:relations]
      rescue ::Parser::SyntaxError
        warn "SyntaxError in #{file}"
      end

      def constants_from_file
        contents = ::File.read(file)

        buffer = ::Parser::Source::Buffer.new(file, 1)
        buffer.source = contents.force_encoding(Encoding::UTF_8)

        ast = parser.parse(buffer)
        parse_block(ast)
      end

      def parser
        parser = ::Parser::CurrentRuby.new(Builder.new)
        parser.diagnostics.ignore_warnings = true
        parser.diagnostics.all_errors_are_fatal = false
        parser
      end

      def valid_file?(file)
        !::File.symlink?(file) &&
          ::File.file?(file) &&
          ::File.size(file) <= FILE_SIZE_LIMIT
      end

      private

      def parse_block(node, parents = [])
        return empty_result unless valid_node?(node)

        case node.type
        when :module then parse_module(node, parents)
        when :class then parse_class(node, parents)
        when :const then parse_const(node, parents)
        else parse_array(node.children, parents)
        end
      end

      def parse_module(node, parents = [])
        namespace = ast_consts_to_array(node.children.first, parents)
        definition = build_definition(Definition::Module, namespace, node)
        constants = { definitions: [definition] }
        children_constants = parse_array(node.children[1..-1], namespace)

        merge_constants(children_constants, constants)
      end

      def build_definition(klass, namespace, node)
        klass.new(
          namespace,
          file: file,
          line: node.loc.line,
          lines: node.loc.last_line - node.loc.line + 1
        )
      end

      def parse_class(node, parents = [])
        namespace = ast_consts_to_array(node.children.first, parents)
        definition = build_definition(Definition::Class, namespace, node)
        constants = { definitions: [definition] }
        children_constants = parse_array(node.children[1..-1], namespace)

        merge_constants(children_constants, constants)
      end

      def parse_const(node, parents = [])
        constant = ast_consts_to_array(node)
        definition = Relation::Base.new(
          constant,
          parents,
          file: file,
          line: node.loc.line
        )
        { relations: [definition] }
      end

      def parse_array(arr, parents = [])
        arr.map { |n| parse_block(n, parents) }
           .reduce { |a, e| merge_constants(a, e) }
      end

      def merge_constants(const1, const2)
        const1 ||= {}
        const2 ||= {}
        {
          definitions: const1[:definitions].to_a + const2[:definitions].to_a,
          relations: const1[:relations].to_a + const2[:relations].to_a
        }
      end

      def ast_consts_to_array(node, parents = [])
        return parents unless valid_node?(node) &&
                              %I[const cbase].include?(node.type)

        ast_consts_to_array(node.children.first, parents) + [node.children.last]
      end

      def empty_result
        {}
      end

      def valid_node?(node)
        node.is_a?(::Parser::AST::Node)
      end
    end
  end
end
