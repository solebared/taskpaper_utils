require "./lib/taskpaper_tools/line_item.rb"

module TaskpaperTools
  describe LineItem do
    #todo: spec Document
    #it "retains the last two components of the filename (w/o .taskpaper extension)"
    #it "contains tasks and notes that don't belong to a projcect"

    describe 'initialization' do
      it 'requires a line of text and a LineItem representing the preceding line' do
        expect {
          first_item = line_item("The first line has no preceding one - we pass the Document", Document.new)
          second_item = line_item("subsequent lines are initialized with their predecessor", first_item)
        }.to_not raise_error
      end
    end

    describe '#type' do
      it ('recognizes a project line') { expect(line_item("a project:")).to be_project } 
      it ('recognizes a task line'   ) { expect(line_item("- a task"  )).to be_task    }
      it ('recognizes a note'        ) { expect(line_item("a note"    )).to be_note    }

      #todo edge cases:
      # - this is a task though it ends with a colon:
      #
    end

    describe 'item nesting:' do

      #todo: what happens to blank lines? -- always a child of previous entry?

      describe 'first child (indented relative to preceding line)' do
        let(:first_item)  { line_item("project:") }
        let(:second_item) { line_item("\t- task x", first_item) }

        it "sets the previous item as it's parent" do
          expect(second_item.parent).to eql first_item
        end

        it "adds itself as a child of the preceding item" do
          expect(first_item.children).to include(second_item)
        end
      end

      describe "subsequent child (same indent as preceding line)" do
        let(:first_item)  { line_item("project:") }
        let(:second_item) { line_item("\t- task x", first_item) }
        let(:third_item)  { line_item("\t- task y", second_item) }

        it "sets the preceding item's parent as it's own parent" do
          expect(third_item.parent).to eql first_item
        end

        it "adds itself as a child of the preceding item's parent" do
          expect(first_item.children).to include(third_item)
        end

        it "appends itself to the end of the parent's collection of children" do
          fourth_item = line_item("\t- task z", third_item)
          expect(first_item.children.last).to be fourth_item
        end
      end

      describe 'unindented lines:' do

        describe 'not within a project' do

          specify 'are children of the Document' do
            document = Document.new
            first_item  = line_item("line one", document)
            second_item = line_item("line two", first_item)
            expect(first_item.parent).to  eql document
            expect(second_item.parent).to eql document
            expect(document.children.size).to eql 2
          end

          specify 'including projects on consecutive lines' do
            document = Document.new
            first_item  = line_item("project a:", document)
            second_item = line_item("project b:", first_item)
            expect(first_item.parent).to  eql document
            expect(second_item.parent).to eql document
          end
        end

        describe 'under a project' do
          specify 'belong to the project' do
            project_item  = line_item("project a:")
            task_item     = line_item("- task a", project_item)
            expect(task_item.parent).to eql project_item
          end
        end

      end

      describe "multiple indents and outdents:" do
        let(:project_a)    { line_item("project a:"                           ) }
        let(:task_x)       { line_item("\t- task x",              project_a   ) }
        let(:subtask_of_x) { line_item("\t\t- subtask of task x", task_x      ) }
        let(:task_y)       { line_item("\t- task y",              subtask_of_x) }
        let(:subtask_of_y) { line_item("\t\t- subtask of task y", task_y      ) }
        let(:project_b)    { line_item("project b:",              subtask_of_y) }

        specify "subtasks are children of tasks" do
          expect(subtask_of_x.parent).to eql task_x
          expect(subtask_of_y.parent).to eql task_y
        end

        describe "outdenting by one level" do
          it "means the item is a sibling of the preceding item's parent" do
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
          expect(line_item("No indents on this line"  ).indents).to eql 0
          expect(line_item("\tOne on this line"       ).indents).to eql 1
          expect(line_item("\t\tTwo on this line"     ).indents).to eql 2
          expect(line_item("\t\t  Two here as well"   ).indents).to eql 2
          expect(line_item(" \tLeading spaces ignored").indents).to eql 1
        end
      end

    end

    describe '#text:' do
      it 'strips line terminators' do
        expect(line_item("a line\n").text).to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(line_item("  \tspacious  ").text).to eql "\tspacious"
      end

    end

    describe '#serialize' do
      let(:collector) { StringIO.new }

      it "provides it's text to the collector" do
        line_item("a task").serialize collector
        expect(collector.string).to eql("a task\n")
      end

      it "provides it's children's text to the collector" do
        project = line_item("project:"                 )
        task    = line_item("\t- task",      project   )
        subtask = line_item("\t\t- subtask", task      )
        project.serialize collector
        expect(collector.string).to eql "project:\n\t- task\n\t\t- subtask\n"
      end
    end

    def line_item(text, previous_item = Document.new)
      LineItem.new text, previous_item
    end
  end
end
