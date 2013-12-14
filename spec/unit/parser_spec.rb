require 'spec_helper'

module TaskpaperUtils
  describe Parser do

    let(:parser) { Parser.new }

    it 'parses an Enumerable and returns a Document' do
      expect(parser.parse(['project:', '- task'])).to be_a(Document)
    end

    describe '#create_entry' do

      describe 'recognizes basic entry types' do
        it('recognizes a project') { expect(entry('a project:')).to be_a Project }
        it('recognizes a task   ') { expect(entry('- a task  ')).to be_a Task    }
        it('recognizes a note   ') { expect(entry('a note    ')).to be_a Note    }
      end

      describe 'edge cases:' do
        it 'recognizes tasks that end with a colon' do
          expect(entry '- task or project?:').to be_a Task
        end
        # todo: other edge cases?
      end

    end

    describe 'parent indentification' do

      # todo: what happens to blank lines? -- always a child of previous entry?

      describe 'first child (indented relative to preceding line)' do
        let(:first)  { entry('project:') }
        let(:second) { entry("\t- task x", first) }

        it 'identifies the previous entry as the parent' do
          expect(parent_of(second, first)).to eql first
        end

        it 'adds the current entry as a child of the preceding entry' do
          expect(first.children).to include(second)
        end
      end

      describe 'sibling child (same indent as preceding line)' do
        let(:first)  { entry('project:') }
        let(:second) { entry("\t- task x", first) }
        let(:third)  { entry("\t- task y", first) }

        it "identifies the preceding entry's parent as the current entry's own parent" do
          expect(parent_of(third, second)).to eql first
        end

        it "adds the current entry as a child of the preceding entry's parent" do
          expect(first.children).to include(third)
        end

        it "appends current entry to the end of parent's collection of children" do
          fourth = entry("\t- task z", first)
          expect(first.children.last).to be fourth
        end
      end

      describe 'unindented lines:' do

        describe 'not within a project' do

          specify 'are children of the Document' do
            document = Document.new
            first  = entry('line one', document)
            second = entry('line two', document)
            expect(parent_of(first, document)).to eql document
            expect(parent_of(second, first)).to eql document
            expect(document.children.size).to eql 2
          end

          specify 'including projects on consecutive lines' do
            document = Document.new
            first  = entry('project a:', document)
            second = entry('project b:', document)
            expect(parent_of(first, document)).to eql document
            expect(parent_of(second, first)).to eql document
          end

          specify 'even when a project is preceded by an unindented task' do
            document = Document.new
            project_a = entry('project a:', document)
            task_of_a = entry('- unindented', project_a)
            project_b = entry('project b:', document)
            expect(parent_of(project_b, task_of_a)).to eql document
          end
        end

        describe 'under a project' do
          specify 'belong to the project even without indents' do
            project_entry  = entry('project a:')
            task_entry     = entry('- task a', project_entry)
            expect(parent_of(task_entry, project_entry)).to eql project_entry
          end
        end
      end

      describe 'multiple indents and outdents:' do
        let(:document)     { Document.new }
        let(:project_a)    { entry 'project a:',              document  }
        let(:task_x)       { entry "\t- task x",              project_a }
        let(:subtask_of_x) { entry "\t\t- subtask of task x", task_x    }
        let(:task_y)       { entry "\t- task y",              project_a }
        let(:subtask_of_y) { entry "\t\t- subtask of task y", task_y    }
        let(:project_b)    { entry 'project b:',              document  }

        specify 'subtasks are children of tasks' do
          expect(parent_of(subtask_of_x, task_x)).to eql task_x
          expect(parent_of(subtask_of_y, task_y)).to eql task_y
        end

        describe 'outdenting by one level' do
          it "means the entry is a sibling of the preceding entry's parent" do
            expect(parent_of(task_y, subtask_of_x)).to eql project_a
          end
        end

        describe 'outdenting by more than one level' do
          it 'should identify the correct parent' do
            expect(parent_of(project_b, subtask_of_y)).to eql document
          end
        end

        # todo: edge cases?
      end

      def parent_of(current_entry, preceding_entry)
        EntryPair.new(preceding_entry, current_entry).identify_parent
      end
    end

    def entry(raw_text, parent = Document.new)
      parser.create_entry(raw_text).tap do |entry|
        parent.add_child(entry)
      end
    end

  end
end
