require 'spec_helper'

module TaskpaperUtils
  describe EntryContainer do
    include ParsingHelpers

    describe '#dump' do

      it "yields it's raw text" do
        expect { |b| new_entry('a task').dump(&b) }.to yield_with_args 'a task'
      end

      it "provides it's children's raw text to the collector" do
        project = new_entry('project:')
        project.add_child new_entry("\t- task")
        project.add_child new_entry("\t\t- subtask")
        expect { |b| project.dump(&b) }
        .to yield_successive_args 'project:', "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          document.add_child new_entry("\t- one")
          document.add_child new_entry("\t- two")
          expect { |b| document.dump(&b) }
          .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end

    describe '#children of type' do

      it 'finds children of the specified type' do
        project = new_entry('project:')
        task = project.add_child new_entry("\t- task")
        note = project.add_child new_entry("\ta note")
        expect(project.children_of_type(:task)).to include task
        expect(project.children_of_type(:task)).to_not include note
      end

    end

    describe '#add_child' do

      specify "adding a child sets it's parent" do
        project = new_entry('project:')
        task    = project.add_child new_entry('- task')
        expect(task.parent).to eql project
      end

    end

    describe '#[]' do

      let(:project) { new_entry('p:') }
      let!(:note)   { project.add_child(new_entry('a note')) }
      let!(:task)   { project.add_child(new_entry('- a task')) }

      it 'finds a child referenced by text' do
        expect(project['a note']).to eq(note)
      end

      it 'uses the text stripped of signifiers (such as the dash before a task)' do
        expect(project['a task']).to eq(task)
      end

      it 'matches the whole text, not just a part of it' do
        expect(project['a']).to be_nil
      end

      describe 'text with @tags' do

        let!(:tagged) { project.add_child(new_entry('- with @a(tag)')) }

        it 'allows referencing without trailing tag' do
          expect(project['with']).to eq(tagged)
        end

        it 'allows referencing with the whole text including tags' do
          expect(project['with @a(tag)']).to eq(tagged)
        end
      end
    end
  end
end
