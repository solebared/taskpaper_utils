require 'spec_helper'

module TaskpaperUtils
  describe Entry do
    include ParsingHelpers

    let(:entry) { new_entry('any entry') }

    it 'generates getters for notes and tasks' do
      expect(entry.public_methods).to include(:notes, :tasks)
    end

    it 'aliases #tasks as #subtasks' do
      entry.add_child(new_entry('- subtask'))
      expect(entry.subtasks).to eql(entry.tasks)
    end

    it 'delegates #document to its parent' do
      entry.parent = double('parent-entry')
      entry.parent.should_receive('document')
      entry.document
    end

    describe 'tags' do

      describe 'initializing and retrieving tags' do

        before do
          entry.tags = [['empty', nil], %w(with value)]
        end

        it 'returns nil if the tag does not exist' do
          expect(entry.tag('nope')).to be_nil
        end

        it 'returns true if the tag exists without a value' do
          expect(entry.tag('empty')).to equal(true)
        end

        it 'returns value if the tag exists with a value' do
          expect(entry.tag('with')).to eql('value')
        end

      end
    end

    describe '#matches?' do

      let(:entry) { new_entry("\t- a task") }

      it 'uses the text stripped of signifiers (such as the dash before a task)' do
        expect(entry.matches?('a task')).to be_true
      end

      it 'matches the whole text, not just a part of it' do
        expect(entry.matches?('a')).to be_false
      end

      describe 'text with @tags' do

        let!(:tagged) { new_entry('- with @a(tag)') }

        it 'matches without trailing tag' do
          expect(tagged.matches?('with')).to be_true
        end

        it 'matches with the whole text including tags' do
          expect(tagged.matches?('with @a(tag)')).to be_true
        end
      end

    end
  end
end
