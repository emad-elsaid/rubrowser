class Tree
  attr_reader :value, :children

  def initialize(value)
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
      children: children.map(&:to_h)
    }
  end
end
