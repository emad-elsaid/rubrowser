module Parser
  class File
    FILE_SIZE_LIMIT = 2 * 1024 * 1024

    attr_reader :file, :definitions, :occurences

    def initialize(file)
      @file = file
      @definitions = Set.new
      @occurences = []
    end

    def parse
      if file_valid?(file)
        ::File.open(file) do |f|
          code = f.read
          ast = Parser::CurrentRuby.parse(code)
          constants = parse_block(ast)
          self.definitions = constants[:definitions].uniq
          self.occurences = constants[:occurences].uniq
        end
      end
      self
    end

    def file_valid?(file)
      !::File.symlink?(file) && ::File.file?(file) && ::File.size(file) <= FILE_SIZE_LIMIT
    end

    def count
      1
    end

    private

    attr_writer :definitions, :occurences

    def parse_block(node, parents = [])
      return { definitions: [], occurences: [] } unless node.is_a?(Parser::AST::Node)

      case node.type
      when :module
        parse_module(node, parents)
      when :class
        parse_class(node, parents)
      when :const
        parse_const(node, parents)
      else
        node
          .children
          .map { |n| parse_block(n, parents) }
          .reduce { |a, e| merge_constants(a, e) } || { definitions: [], occurences: [] }
      end
    end

    def parse_module(node, parents = [])
      name = resolve_const_path(node.children.first, parents)
      node
        .children[1..-1]
        .map { |n| parse_block(n, name) }
        .reduce { |a, e| merge_constants(a, e) }
        .tap { |constants| constants[:definitions].unshift(name) }
    end

    def parse_class(node, parents = [])
      name = resolve_const_path(node.children.first, parents)
      node
        .children[1..-1]
        .map { |n| parse_block(n, name) }
        .reduce { |a, e| merge_constants(a, e) }
        .tap { |constants| constants[:definitions].unshift(name) }
    end

    def parse_const(node, parents = [])
      constant = resolve_const_path(node)
      namespace = parents[0...-1]
      constants = if namespace.empty? || constant.first.nil?
                    [{ parents => [constant.compact] }]
                  else
                    [{ parents => (namespace.size-1).downto(0).map { |i| namespace[0..i] + constant }.push(constant) }]
                  end
      { definitions: [], occurences: constants }
    end

    def merge_constants(constants1, constants2)
      {
        definitions: constants1[:definitions] + constants2[:definitions],
        occurences: constants1[:occurences] + constants2[:occurences]
      }
    end

    def resolve_const_path(node, parents = [])
      return parents unless node.is_a?(Parser::AST::Node) && [:const, :cbase].include?(node.type)
      resolve_const_path(node.children.first, parents) + [node.children.last]
    end
  end
end
