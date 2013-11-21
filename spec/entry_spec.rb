require "spec_helper"

module TaskpaperTools
  describe Entry do
    include EntrySpecHelpers

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
            first = entry("The first line has no preceding one - we pass the Document", Document.new)
            second = entry("subsequent lines are initialized with their predecessor", first)
          }.to_not raise_error
        end
      end

    end

    describe 'entry nesting:' do

      #todo: what happens to blank lines? -- always a child of previous entry?

      describe 'first child (indented relative to preceding line)' do
        let(:first)  { entry("project:") }
        let(:second) { entry("\t- task x", first) }

        it "sets the previous entry as it's parent" do
          expect(first).to be_identified_as_the_parent_given(first, second)
        end

        it "adds itself as a child of the preceding entry", pending: 'move to parser_spec' do
          expect(first.children).to include(second)
        end
      end

      describe "sibling child (same indent as preceding line)" do
        let(:first)  { entry("project:") }
        let(:second) { entry("\t- task x", first) }
        let(:third)  { entry("\t- task y", first) }

        it "sets the preceding entry's parent as it's own parent" do
          expect(first).to be_identified_as_the_parent_given(second, third)
        end

        it "adds itself as a child of the preceding entry's parent", pending: 'move to parser_spec'  do
          expect(first.children).to include(third)
        end

        it "appends itself to the end of the parent's collection of children" , pending: 'move to parser_spec' do
          fourth = entry("\t- task z", third)
          expect(first.children.last).to be fourth
        end
      end

      describe 'unindented lines:' do

        describe 'not within a project' do

          specify 'are children of the Document' do
            document = Document.new
            first  = entry("line one", document)
            second = entry("line two", document)
            expect(document).to be_identified_as_the_parent_given(document, first)
            expect(document).to be_identified_as_the_parent_given(first, second)
            #todo: move to parser? expect(document.children.size).to eql 2
          end

          specify 'including projects on consecutive lines' do
            document = Document.new
            first  = entry("project a:", document)
            second = entry("project b:", document)
            expect(document).to be_identified_as_the_parent_given(document, first)
            expect(document).to be_identified_as_the_parent_given(first, second)
          end

          specify 'even when a project is preceded by an unindented task' do
            document = Document.new
            project_a = entry("project a:", document)
            task_of_a = entry("- unindented", project_a)
            project_b = entry("project b:", document)
            expect(document).to be_identified_as_the_parent_given(task_of_a, project_b)
          end
        end

        describe 'under a project' do
          specify 'belong to the project even without indents' do
            project_entry  = entry("project a:")
            task_entry     = entry("- task a", project_entry)
            expect(project_entry).to be_identified_as_the_parent_given(project_entry, task_entry)
          end
        end
      end

      describe "multiple indents and outdents:" do
        let(:document)     { Document.new }
        let(:project_a)    { entry("project a:",              document    ) }
        let(:task_x)       { entry("\t- task x",              project_a   ) }
        let(:subtask_of_x) { entry("\t\t- subtask of task x", task_x      ) }
        let(:task_y)       { entry("\t- task y",              project_a   ) }
        let(:subtask_of_y) { entry("\t\t- subtask of task y", task_y      ) }
        let(:project_b)    { entry("project b:",              document    ) }

        specify "subtasks are children of tasks" do
          expect(task_x).to be_identified_as_the_parent_given(task_x, subtask_of_x)
          expect(task_y).to be_identified_as_the_parent_given(task_y, subtask_of_y)
        end

        describe "outdenting by one level" do
          it "means the entry is a sibling of the preceding entry's parent" do
            expect(project_a).to be_identified_as_the_parent_given(subtask_of_x, task_y)
          end
        end

        describe "outdenting by more than one level" do
          it "should identify the correct parent" do
            expect(document).to be_identified_as_the_parent_given(subtask_of_y, project_b)
          end

          #todo: edge cases?
        end

        RSpec::Matchers.define :be_identified_as_the_parent_given do |preceding_entry, current_entry|
          match do |expected_parent|
            parser.find_parent_of(preceding_entry, current_entry) == expected_parent
          end
        end
      end

      describe '#indents' do
        it 'calculates the number of indents for a given line from the number of leading tabs' do
          expect(entry("No indents on this line"  ).indents).to eql 0
          expect(entry("\tOne on this line"       ).indents).to eql 1
          expect(entry("\t\tTwo on this line"     ).indents).to eql 2
          expect(entry("\t\t  Two here as well"   ).indents).to eql 2
        end
      end

    end

    describe 'type characteristics' do

      describe '#text' do

        specify 'Tasks strip leading tabs and dash' do
          expect(entry(  "- task").text).to eql 'task'
          expect(entry("\t- task").text).to eql 'task'
        end

        specify 'Projects strip trailing colon' do
          expect(entry("Project:").text).to eql 'Project'
        end
      end
    end

  end
end
