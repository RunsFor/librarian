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

    it 'returns Hash' do
      expect(subject).to be_a_kind_of(Hash)
    end

    describe 'comparing types' do
      context 'when :filename' do
        subject { Librarian.new.dublicates(type: :filename) }

        let(:different_books) { %w(Maths/numbers_theory.pdf Other/jokes.pdf) }
        let(:dublicate_books) { %w(Maths/basic_theory.pdf Other/basic_theory.pdf) }

        it 'excludes uniq books from the result' do
          expect_any_instance_of(Librarian).to receive(:all) { different_books }

          expect(subject).to eq({})
        end

        it 'puts dublicates under one key based on the file name' do
          expect_any_instance_of(Librarian).to receive(:all) { dublicate_books }

          expect(subject['basic_theory.pdf'].size).to eq(2)
        end
      end

      context 'when :sha1' do
        subject { Librarian.new.dublicates(type: :sha1) }

        let(:numbers_theory) do
          file = Tempfile.new([ 'numbers_theory', '.pdf' ])
          file.write('some interesting numbers theory')
          file.close
          file
        end

        let(:jokes) do
          file = Tempfile.new([ 'jokes', '.pdf' ])
          file.write('some funny jokes')
          file.close
          file
        end

        let(:mathematics) do
          file = Tempfile.new([ 'mathematics', '.pdf' ])
          file.write('some interesting numbers theory')
          file.close
          file
        end

        let(:dublicate_books) { [ numbers_theory.path, mathematics.path ] }
        let(:different_books) { [ numbers_theory.path, jokes.path ] }

        it 'puts dublicates under one key even if filenames are distinct' do
          expect_any_instance_of(Librarian).to receive(:all) { dublicate_books }

          dublicate_key = subject.keys.first
          expect(subject[dublicate_key].size).to eq(2)
        end

        it 'excludes uniq books from the result even if filenames are the same' do
          expect_any_instance_of(Librarian).to receive(:all) { different_books }

          expect(subject.size).to eq(0)
        end

        context 'when directory has filetype at the end' do
          let(:directory) do
            Dir.mktmpdir(['math', '.pdf'], '/tmp')
          end

          let(:all_books) do
            [ numbers_theory.path, mathematics.path, jokes.path, directory ]
          end

          it 'skips this directory' do
            expect(Dir).to receive(:glob) { all_books }

            expect{ subject }.to_not raise_error
            expect(subject.size).to eq(1)
          end
        end
      end
    end
  end
end

