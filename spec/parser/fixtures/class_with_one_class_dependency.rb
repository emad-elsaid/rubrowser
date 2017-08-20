class ClassWithOneClassDependency
  def initialize
    ClassWithNoRelations.new
  end
end
