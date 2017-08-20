require 'rubrowser/data'

describe Rubrowser::Data do
  context 'There are dependencies' do
    shared_examples_for 'an empty relation' do
      it 'returns an empty array' do
        definition = double(:definition,
                            namespace: [file_namespace],
                            circular?: false)
        file = Rubrowser::Data.new([File.expand_path(file_path)])

        expect(file.relations).to eq([])
        expect(file.definitions).to eq([definition])
      end
    end

    context 'in a class' do
      let(:file_path) { 'spec/parser/fixtures/class_with_no_relations.rb' }
      let(:file_namespace) { :ClassWithNoRelations }

      it_behaves_like 'an empty relation'
    end

    context 'in a module' do
      let(:file_path) { 'spec/parser/fixtures/module_with_no_relations.rb' }
      let(:file_namespace) { :ModuleWithNoRelations }

      it_behaves_like 'an empty relation'
    end
  end

  shared_examples_for 'a relation' do
    it 'returns an with a relation' do
      namespace = double(:namespace,
                         namespace: [dependency_namespace],
                         circular?: false)
      caller_namespace = double(:caller_namespace,
                                namespace: [file_namespace],
                                circular?: false)

      file = Rubrowser::Data.new([File.expand_path(file_path)])

      relations = file.relations
      expect(relations.length).to eq(1)
      expect(relations.first).to eq(double(:relation,
                                           namespace: namespace,
                                           caller_namespace: caller_namespace,
                                           circular?: false))

      definitions = file.definitions
      expect(definitions.length).to eq(1)
      expect(definitions.first).to eq(caller_namespace)
    end
  end

  context 'Module depends on a class' do
    let(:file_path) do
      'spec/parser/fixtures/module_with_one_class_dependency.rb'
    end

    let(:file_namespace) { :ModuleWithOneClassDependency }
    let(:dependency_namespace) { :ClassWithNoRelations }

    it_behaves_like 'a relation'
  end

  context 'Class has one Mixin' do
    context 'included' do
      let(:file_namespace) { :ClassWithOneIncludedMixin }
      let(:dependency_namespace) { :ModuleWithNoRelations }
      let(:file_path) do
        'spec/parser/fixtures/class_with_one_included_mixin.rb'
      end

      it_behaves_like 'a relation'
    end

    context 'extended' do
      let(:file_namespace) { :ClassWithOneExtendedMixin }
      let(:dependency_namespace) { :ModuleWithNoRelations }
      let(:file_path) do
        'spec/parser/fixtures/class_with_one_extended_mixin.rb'
      end

      it_behaves_like 'a relation'
    end
  end

  context 'Class depends on another class' do
    let(:file_namespace) { :ClassWithOneClassDependency }
    let(:dependency_namespace) { :ClassWithNoRelations }
    let(:file_path) do
      'spec/parser/fixtures/class_with_one_class_dependency.rb'
    end

    it_behaves_like 'a relation'
  end

  context 'Circular dependency' do
    context 'across classes' do
      let(:file_path) { 'spec/parser/fixtures/classes_circular_dependency.rb' }

      it 'returns true' do
        file = Rubrowser::Data.new([File.expand_path(file_path)])

        definitions = file.definitions
        expect(definitions.first.circular?).to eq(true)
        expect(definitions.last.circular?).to eq(true)

        relations = file.relations
        expect(relations.first.circular?).to eq(true)
        expect(relations.last.circular?).to eq(true)
      end
    end
  end
end
