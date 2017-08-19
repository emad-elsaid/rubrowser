require 'rubrowser/parser/file'

describe Rubrowser::Parser::File do

  context 'There are dependencies' do
    shared_examples_for 'an empty relation' do
      it 'returns an empty array' do
        file = Rubrowser::Parser::File.new(File.expand_path(file_path))

        expect(file.parse).to eq([])
      end
    end

    context 'in a class' do
      let(:file_path) {'spec/parser/fixtures/class_with_no_relations.rb'}

      it_behaves_like 'an empty relation'
    end

    context 'in a module' do
      let(:file_path) {'spec/parser/fixtures/module_with_no_relations.rb'}

      it_behaves_like 'an empty relation'
    end
  end

  shared_examples_for 'a relation' do
    it 'returns an with a relation' do
      namespace = double(:namespace, namespace: [dependency_namespace])
      caller_namespace = double(:caller_namespace, namespace: [file_namespace])

      file = Rubrowser::Parser::File.new(File.expand_path(file_path))

      relations = file.parse
      expect(relations.length).to eq(1)
      expect(relations.first).to eq(double(:relation, namespace: namespace,
                                           caller_namespace: caller_namespace))
    end
  end

  context 'Module depends on a class' do
    let(:file_path) {'spec/parser/fixtures/module_with_one_class_dependency.rb'}
    let(:file_namespace) {:ModuleWithOneClassDependency}
    let(:dependency_namespace) {:ClassWithNoRelations}

    it_behaves_like 'a relation'
  end

  context 'Class has one Mixin' do
    context 'included' do
      let(:file_namespace) {:ClassWithOneIncludedMixin}
      let(:dependency_namespace) {:ModuleWithNoRelations}
      let(:file_path) {'spec/parser/fixtures/class_with_one_included_mixin.rb'}

      it_behaves_like 'a relation'
    end

    context 'extended' do
      let(:file_namespace) {:ClassWithOneExtendedMixin}
      let(:dependency_namespace) {:ModuleWithNoRelations}
      let(:file_path) {'spec/parser/fixtures/class_with_one_extended_mixin.rb'}

      it_behaves_like 'a relation'
    end
  end

  context 'Class depends on another class' do
    let(:file_namespace) {:ClassWithOneClassDependency}
    let(:dependency_namespace) {:ClassWithNoRelations}
    let(:file_path) {'spec/parser/fixtures/class_with_one_class_dependency.rb'}

    it_behaves_like 'a relation'
  end
end