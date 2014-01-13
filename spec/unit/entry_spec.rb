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
      expect(entry.subtasks).to eq(entry.tasks)
    end

    it 'delegates #document to its parent' do
      entry.parent = double('parent-entry')
      entry.parent.should_receive('document')
      entry.document
    end

    describe '#tag_value, #tag?' do

      let(:entry) { new_entry('with @empty tag and one @with(value)') }

      describe 'when the tag does not exist' do

        specify '#tag? returns false' do
          expect(entry.tag?('nope')).to equal(false)
        end

        specify '#tag_value returns nil' do
          expect(entry.tag_value('nope')).to be_nil
        end

      end

      describe 'when the tag exists without a value' do

        specify '#tag? returns true' do
          expect(entry.tag?('empty')).to equal(true)
        end

        specify '#tag_value returns an empty string' do
          expect(entry.tag_value('empty')).to eq('')
        end

      end

      describe 'when the tag exists with a value' do

        describe '#tag?' do

          it 'returns true when given no value' do
            expect(entry.tag?('with')).to equal(true)
          end

          it 'returns true given the matching value' do
            expect(entry.tag?('with', 'value')).to equal(true)
          end

          it 'returns false given a different value' do
            expect(entry.tag?('with', 'wrong value')).to equal(false)
          end

          it 'works with symbols' do
            expect(entry.tag?(:with, :value)).to equal(true)
          end

        end

        describe '#tag_value' do

          it 'returns the value' do
            expect(entry.tag_value('with')).to eq('value')
          end

          it 'works with a symbol' do
            expect(entry.tag_value(:with)).to eq('value')
          end

        end
      end

    end

    describe '#text_with_trailing_tags' do

      it 'concatenates text and trailing tags' do
        entry = new_entry('- with @tag')
        expect(entry.text).to eq('with')
        expect(entry.text_with_trailing_tags).to eq('with @tag')
      end

      it 'inserts a colon before trailing tags for projects' do
        project = new_entry('project: @with @tag')
        expect(project.text).to eq('project')
        expect(project.text_with_trailing_tags).to eq('project: @with @tag')
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
