require 'spec_helper'

describe Librarian do
  it { should respond_to :all }
  it { should respond_to :search }
  it { should respond_to :dublicates }

  context '#all' do
    it 'returns an Array' do
      expect(subject.all).to be_a_kind_of(Array)
    end
  end

  context '#search' do
    let(:books) { %w(java/java_tutorial.pdf java/features.pdf) }

    before do
      expect_any_instance_of(Librarian).to receive(:all) { books }
    end

    it 'does search based on filename' do
      expect(subject.search('java')).to match_array(['java/java_tutorial.pdf'])
    end
  end

  context '#dublicates' do
    subject { Librarian.new.dublicates }

    let(:different_books) { %w(Maths/numbers_theory.pdf Other/jokes.pdf) }
    let(:dublicate_books) { %w(Maths/basic_theory.pdf Other/basic_theory.pdf) }

    it 'returns Hash' do
      expect(subject).to be_a_kind_of(Hash)
    end

    it 'excludes uniq books from the result' do
      expect_any_instance_of(Librarian).to receive(:all) { different_books }

      expect(subject).to eq({})
    end

    it 'puts dublicates under one key based on the file name' do
      expect_any_instance_of(Librarian).to receive(:all) { dublicate_books }

      expect(subject['basic_theory.pdf'].size).to eq(2)
    end
  end
end

