require "spec_helper"

module TaskpaperTools
  describe EntryContainer do
    include EntrySpecHelpers

    describe '#yield_raw_text' do

      it "yields it's raw text" do
        expect{ |b| entry("a task").yield_raw_text(&b) }.to yield_with_args "a task"
      end

      it "provides it's children's raw text to the collector" do
        project = entry("project:"                 )
        task    = entry("\t- task",      project   )
        subtask = entry("\t\t- subtask", task      )
        expect{ |b| project.yield_raw_text(&b) }
        .to yield_successive_args "project:", "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          one = entry("\t- one", document)
          two = entry("\t- two", one)
          expect{ |b| document.yield_raw_text(&b) }
          .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end

    describe '#children of type' do

      it 'finds children of the specified type' do
        project = entry("project:"            )
        task    = entry("\t- task", project   )
        subtask = entry("\ta note", task      )
        expect(project.children_of_type(:task)).to eql [task]
      end
    end
  end
end
