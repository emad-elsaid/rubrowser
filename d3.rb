class D3
  def initialize(node)
    @node = node
  end

  def constants
    node_id(node)
  end

  def occurences
    node_occurences(node)
  end

  private

  attr_reader :node

  def node_id(node)
    node.children.map do |n|
      node_id(n)
    end.reduce(:+).to_a.push({ name: node.name, id: node.id })
  end

  def node_occurences(node)
    occurences = []
    occurences += node.children.map { |n| node_occurences(n) }.reduce(:+).to_a

    occurences += node.occurences.map { |n| {source: node.id, target: n.id } }.to_a
    occurences
  end
end
