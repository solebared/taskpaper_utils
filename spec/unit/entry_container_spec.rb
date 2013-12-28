require 'spec_helper'

module TaskpaperUtils
  describe EntryContainer do

    describe '#dump' do

      it "yields it's raw text" do
        expect { |b| Task.new('a task').dump(&b) }.to yield_with_args 'a task'
      end

      it "provides it's children's raw text to the collector" do
        project = Project.new('project:')
        project.add_child Task.new("\t- task")
        project.add_child Task.new("\t\t- subtask")
        expect { |b| project.dump(&b) }
        .to yield_successive_args 'project:', "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          document.add_child Task.new("\t- one")
          document.add_child Task.new("\t- two")
          expect { |b| document.dump(&b) }
          .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end

    describe '#children of type' do

      it 'finds children of the specified type' do
        project = Project.new('project:')
        task = project.add_child Task.new("\t- task")
        note = project.add_child Note.new("\ta note")
        expect(project.children_of_type(:task)).to include task
        expect(project.children_of_type(:task)).to_not include note
      end

    end

    describe '#add_child' do

      specify "adding a child sets it's parent" do
        project = Project.new('project:')
        task    = project.add_child Task.new('- task')
        expect(task.parent).to eql project
      end

    end

    describe '#[]' do

      let(:note) { Note.new('a note')   }
      let(:task) { Task.new('- a task') }
      let(:project)  do
        Project.new('p:').tap do |p|
          p.add_child(note)
          p.add_child(task)
        end
      end

      it 'finds a child referenced by text' do
        expect(project['a note']).to eql(note)
      end

      it 'uses the text stripped of signifiers (such as the dash before a task)' do
        expect(project['a task']).to eql(task)
      end

      it 'matches the whole text, not just a part of it' do
        expect(project['a']).to be_nil
      end
    end
  end
end