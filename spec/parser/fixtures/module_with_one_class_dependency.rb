class ModuleWithOneClassDependency
  def initialize
    ClassWithNoRelations.new
  end
end
