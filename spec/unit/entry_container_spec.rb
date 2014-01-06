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

      it 'finds a child referenced by text' do
        expect(project['a note']).to eq(note)
      end

      # see specs for Entry#matches? for detailed cases
    end
  end
end
