class Tree
  attr_reader :value, :children

  def self.from_parsers(parsers)
    return Tree.new if parsers.empty?

    definitions = parsers.map(&:definitions).reduce(:+).uniq
    occurences = parsers.map(&:occurences).reduce(:+).uniq
    Tree.new.tap do |tree|
      definitions.each { |definition| tree.add_child(definition) }
    end
  end

  def initialize(value = nil)
    @value = value
    @children = Set.new
  end

  def add_child(child_name_path = [])
    return if child_name_path.empty?
    child = get_or_create_child(child_name_path[0])
    children.add(child)
    child.add_child(child_name_path[1..-1])
  end

  def get_or_create_child(child_name)
    children.find { |child| child_name == child.value } || Tree.new(child_name)
  end

  def eq?(other)
    other.value == value
  end

  def to_h
    {
      const: value,
    }.tap do |hash|
      hash[:children] = children.map(&:to_h) unless children.empty?
    end
  end
end
