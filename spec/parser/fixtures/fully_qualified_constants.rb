module ::Quz
end

class ::A
  include ::Quz

  def initialize
    ::B.do
  end

  def self.do; end
end

class ::B
  def initialize
    ::A.do
  end

  def self.do; end
end

class ::C
  include ::Quz

  def initialize
    ::A.do
  end

  def self.do; end
end
