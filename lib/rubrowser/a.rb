class A
  def initialize
    B.do
  end

  def self.do

  end
end

class B
  def initialize
    C.do
  end

  def self.do

  end
end

class C
  def initialize
    A.do
  end

  def self.do

  end
end