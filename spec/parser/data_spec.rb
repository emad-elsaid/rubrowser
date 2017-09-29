require 'rubrowser/data'
require 'spec_helper'

describe Rubrowser::Data do
  context 'There are dependencies' do
    shared_examples_for 'an empty relation' do
      it 'returns an empty array' do
        file = Rubrowser::Data.new([file_path])

        expect(file.relations).to eq([])
        expect(file.definitions.first.circular?).to eq(false)
        expect(file.definitions.first.namespace).to eq([file_namespace])
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

  context 'When there are circular relations' do
    let(:non_circular_index) { 2 }

    let(:file_path) do
      'spec/parser/fixtures/class_related_to_circular_dependency.rb'
    end

    let(:file) { Rubrowser::Data.new([file_path]) }
    let(:definitions) { file.definitions }
    let(:relations) { file.relations }

    it 'marks relations that are circular' do
      expect(relations[0].circular?).to eq(true)
      expect(relations[1].circular?).to eq(true)
    end

    it 'does NOT mark non-circular relations near the circular relation' do
      expect(relations[non_circular_index].circular?).to eq(false)
    end

    it 'marks definitions that are circular' do
      expect(definitions[0].circular?).to eq(true)
      expect(definitions[1].circular?).to eq(true)
    end

    it 'does NOT mark non-circular definition near the circular definition' do
      expect(definitions[non_circular_index].circular?).to eq(false)
    end
  end
end
