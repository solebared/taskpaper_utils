require "./lib/taskpaper_tools/entry"

module TaskpaperTools
  describe Entry do
    #todo: spec Document
    #it "contains tasks and notes that don't belong to a projcect"

    def entry(text, previous_entry = Document.new)
      Entry.create text, previous_entry
    end

    describe '.create' do

      describe 'recognizes basic entry types' do
        it ('recognizes a project') { expect(entry("a project:")).to be_a(Project)} 
        it ('recognizes a task   ') { expect(entry("- a task"  )).to be_a(Task   )}
        it ('recognizes a note   ') { expect(entry("a note"    )).to be_a(Note   )}
      end

      describe 'edge cases:' do

        it 'recognizes tasks that end with a colon' do
           expect(entry "- task or project?:" ).to be_a Task
        end

        #todo other edge cases?
      end

      describe 'initialization' do
        it 'requires a line of text and an Entry representing the preceding line' do
          expect {
            first_entry = entry("The first line has no preceding one - we pass the Document", Document.new)
            second_entry = entry("subsequent lines are initialized with their predecessor", first_entry)
          }.to_not raise_error
        end
      end

    end

    describe 'entry nesting:' do

      #todo: what happens to blank lines? -- always a child of previous entry?

      describe 'first child (indented relative to preceding line)' do
        let(:first_entry)  { entry("project:") }
        let(:second_entry) { entry("\t- task x", first_entry) }

        it "sets the previous entry as it's parent" do
          expect(second_entry.parent).to eql first_entry
        end

        it "adds itself as a child of the preceding entry" do
          expect(first_entry.children).to include(second_entry)
        end
      end

      describe "sibling child (same indent as preceding line)" do
        let(:first_entry)  { entry("project:") }
        let(:second_entry) { entry("\t- task x", first_entry) }
        let(:third_entry)  { entry("\t- task y", second_entry) }

        it "sets the preceding entry's parent as it's own parent" do
          expect(third_entry.parent).to eql second_entry.parent
          expect(third_entry.parent).to eql first_entry
        end

        it "adds itself as a child of the preceding entry's parent" do
          expect(first_entry.children).to include(third_entry)
        end

        it "appends itself to the end of the parent's collection of children" do
          fourth_entry = entry("\t- task z", third_entry)
          expect(first_entry.children.last).to be fourth_entry
        end
      end


      describe 'unindented lines:' do

        describe 'not within a project' do

          specify 'are children of the Document' do
            document = Document.new
            first_entry  = entry("line one", document)
            second_entry = entry("line two", first_entry)
            expect(first_entry.parent).to  eql document
            expect(second_entry.parent).to eql document
            expect(document.children.size).to eql 2
          end

          specify 'including projects on consecutive lines' do
            document = Document.new
            first_entry  = entry("project a:", document)
            second_entry = entry("project b:", first_entry)
            expect(first_entry.parent).to  eql document
            expect(second_entry.parent).to eql document
          end

          specify 'even when a project is preceded by an unindented task' do
            document = Document.new
            project_a = entry("project a:", document)
            task_of_a = entry("- unindented", project_a)
            project_b = entry("project b:", task_of_a)
            expect(project_a.parent).to eql document
            expect(project_b.parent).to eql document
          end
        end

        describe 'under a project' do
          specify 'belong to the project even without indents' do
            project_entry  = entry("project a:")
            task_entry     = entry("- task a", project_entry)
            expect(task_entry.parent).to eql project_entry
          end
        end

      end

      describe "multiple indents and outdents:" do
        let(:project_a)    { entry("project a:"                           ) }
        let(:task_x)       { entry("\t- task x",              project_a   ) }
        let(:subtask_of_x) { entry("\t\t- subtask of task x", task_x      ) }
        let(:task_y)       { entry("\t- task y",              subtask_of_x) }
        let(:subtask_of_y) { entry("\t\t- subtask of task y", task_y      ) }
        let(:project_b)    { entry("project b:",              subtask_of_y) }

        specify "subtasks are children of tasks" do
          expect(subtask_of_x.parent).to eql task_x
          expect(subtask_of_y.parent).to eql task_y
        end

        describe "outdenting by one level" do
          it "means the entry is a sibling of the preceding entry's parent" do
            expect(task_y.parent).to eql project_a
          end
        end

        describe "outdenting by more than one level" do
          it "should identify the correct parent" do
            #both projects should have the same Document parent
            expect(project_b.parent).to eql project_a.parent
          end

          #todo: edge cases
        end

      end

      describe '#indents' do
        it 'calculates the number of indents for a given line from the number of leading tabs' do
          expect(entry("No indents on this line"  ).indents).to eql 0
          expect(entry("\tOne on this line"       ).indents).to eql 1
          expect(entry("\t\tTwo on this line"     ).indents).to eql 2
          expect(entry("\t\t  Two here as well"   ).indents).to eql 2
          expect(entry(" \tLeading spaces ignored").indents).to eql 1
        end
      end

    end

    describe '#text:' do
      it 'strips line terminators' do
        expect(entry("a line\n").text).to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(entry("  \tspacious  ").text).to eql "\tspacious"
      end

    end

    describe '#yield_text' do

      it "yields it's text" do
        expect{ |b| entry("a task").yield_text(&b) }.to yield_with_args "a task"
      end

      it "provides it's children's text to the collector" do
        project = entry("project:"                 )
        task    = entry("\t- task",      project   )
        subtask = entry("\t\t- subtask", task      )
        expect{ |b| project.yield_text(&b) }
          .to yield_successive_args "project:", "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          one = entry("\t- one", document)
          two = entry("\t- two", one)
          expect{ |b| document.yield_text(&b) }
            .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end
  end
end
