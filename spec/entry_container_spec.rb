require "spec_helper"

module TaskpaperTools
  describe EntryContainer do

    describe '#yield_raw_text' do

      it "yields it's raw text" do
        expect{ |b| Task.new("a task").yield_raw_text(&b) }.to yield_with_args "a task"
      end

      it "provides it's children's raw text to the collector" do
        project = Project.new("project:")
        task = project.add_child Task.new("\t- task")
               project.add_child Task.new("\t\t- subtask")
        expect{ |b| project.yield_raw_text(&b) }
        .to yield_successive_args "project:", "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          document.add_child Task.new("\t- one")
          document.add_child Task.new("\t- two")
          expect{ |b| document.yield_raw_text(&b) }
          .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end

    describe '#children of type' do

      it 'finds children of the specified type' do
        project = Project.new("project:")
        task = project.add_child Task.new("\t- task")
        note = project.add_child Note.new("\ta note")
        expect(project.children_of_type(:task)).to include task
        expect(project.children_of_type(:task)).to_not include note
      end
    end
  end
end
