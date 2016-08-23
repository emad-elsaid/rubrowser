class Tree
  attr_reader :value, :children, :occurences, :parent

  def self.from_parsers(parsers)
    return Tree.new if parsers.empty?

    definitions = parsers.map(&:definitions).reduce(:+).uniq
    occurences = parsers.map(&:occurences).reduce(:+).uniq
    Tree.new.tap do |tree|
      definitions.each { |definition| tree.add_child(definition) }
      occurences.each { |occurence| tree.add_occurence(*occurence.first) }
    end
  end

  def initialize(value = nil, parent = nil)
    @value = value
    @parent = parent
    @children = Set.new
    @occurences = Set.new
  end

  def id
    return value if parent.nil? || parent.id.nil?
    "#{parent.id}::#{value}".to_sym
  end

  def add_child(child_name_path = [])
    return if child_name_path.empty?
    child = get_or_create_child(child_name_path[0])
    children.add(child)
    child.add_child(child_name_path[1..-1])
  end

  def add_occurence(user, constants)
    user_node = find_node(user)
    occured_node = constants.map { |constant| find_node(constant) }.compact.first
    return unless user_node && occured_node
    user_node.occurences << occured_node
  end

  def find_node(path)
    return self if path.empty?
    child = children.find { |c| c.value == path.first }
    return unless child
    child.find_node(path[1..-1])
  end

  def get_or_create_child(child_name)
    children.find { |child| child_name == child.value } || Tree.new(child_name, self)
  end

  def eq?(other)
    other.value == value
  end

  def to_h
    {
      const: value
    }.tap do |hash|
      hash[:children] = children.map(&:to_h) unless children.empty?
      hash[:occurences] = occurences.map(&:id) unless occurences.empty?
    end
  end

  private

  attr_writer :occurences
end
