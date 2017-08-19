require 'rubrowser/parser/file'

describe Rubrowser::Parser::File do
  it 'returns an empty array' do
    file_with_no_relations = File.expand_path('spec/parser/fixtures/class_with_no_relations.rb')

    file = Rubrowser::Parser::File.new(file_with_no_relations)

    expect(file.parse).to eq([])
  end

  it 'returns an empty array' do
    module_with_no_relations = File.expand_path('spec/parser/fixtures/module_with_no_relations.rb')

    file = Rubrowser::Parser::File.new(module_with_no_relations)

    expect(file.parse).to eq([])
  end

  it 'returns an with a relation' do
    class_with_one_included_mixin = File.expand_path('spec/parser/fixtures/class_with_one_included_mixin.rb')
    namespace = double(:namespace, namespace: [:ModuleWithNoRelations])
    caller_namespace = double(:caller_namespace, namespace: [:ClassWithOneIncludedMixin])

    file = Rubrowser::Parser::File.new(class_with_one_included_mixin)

    relations = file.parse
    expect(relations.length).to eq(1)
    expect(relations.first).to eq(double(:relation, namespace: namespace,
                                         caller_namespace: caller_namespace))
  end

  it 'returns an with a relation' do
    class_with_one_extended_mixin = File.expand_path('spec/parser/fixtures/class_with_one_extended_mixin.rb')
    namespace = double(:namespace, namespace: [:ModuleWithNoRelations])
    caller_namespace = double(:caller_namespace, namespace: [:ClassWithOneExtendedMixin])

    file = Rubrowser::Parser::File.new(class_with_one_extended_mixin)

    relations = file.parse
    expect(relations.length).to eq(1)
    expect(relations.first).to eq(double(:relation, namespace: namespace,
                                         caller_namespace: caller_namespace))
  end

  it 'returns an with a relation' do
    one_class_dependency = File.expand_path('spec/parser/fixtures/class_with_one_class_dependency.rb')
    namespace = double(:namespace, namespace: [:ClassWithNoRelations])
    caller_namespace = double(:caller_namespace, namespace: [:ClassWithOneClassDependency])

    file = Rubrowser::Parser::File.new(one_class_dependency)

    relations = file.parse
    expect(relations.length).to eq(1)
    expect(relations.first).to eq(double(:relation, namespace: namespace,
                                         caller_namespace: caller_namespace))
  end
end