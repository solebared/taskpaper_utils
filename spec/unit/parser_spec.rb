require 'spec_helper'

module TaskpaperUtils
  describe Parser do

    describe 'create_entry' do

      describe 'recognizes basic entry types' do
        specify('a project') { expect('a project:').to be_identified_as_a(:project) }
        specify('a task   ') { expect('- a task  ').to be_identified_as_a(:task) }
        specify('a note   ') { expect('a note    ').to be_identified_as_a(:note) }
      end

      describe 'edge cases:' do
        it 'recognizes tasks that end with a colon' do
          expect('- task or project?:').to be_identified_as_a(:task)
        end
      end

      RSpec::Matchers.define :be_identified_as_a do |type|
        match do |raw_text|
          Parser.create_entry(raw_text).type == type
        end
      end

    end

    describe 'parent indentification' do

      let(:parser) { Parser.new }

      describe 'simple indentation:' do

        let(:project) { doc['project'] }
        let(:doc) do
          parse "project:
                 \t- task x
                 \t- task y"
        end

        describe 'entry indented relative to preceding entry' do
          it 'identifies the previous entry as the parent' do
            expect(project).to be_parent_of('task x')
          end
        end

        describe 'sibling entry (same indent as preceding line)' do

          it "identifies the preceding entry's parent as its own parent" do
            expect(project).to be_parent_of('task y')
          end

          it "appends to the end of parent's collection of children" do
            expect(project.children.last.text).to eql('task y')
          end

        end
      end

      describe 'unindented lines:' do

        describe 'not within a project' do

          specify 'are children of the Document' do
            doc = parse("one\ntwo")
            expect(doc).to be_parent_of('one')
            expect(doc).to be_parent_of('two')
            expect(doc).to have(2).children
          end

          specify 'including projects on consecutive lines' do
            doc = parse("project a:\nproject b:")
            expect(doc).to be_parent_of('project a')
            expect(doc).to be_parent_of('project b')
          end

          specify 'even when a project is preceded by an unindented task' do
            doc = parse "project a:
                         - unindented
                         project b:"
            expect(doc).to be_parent_of('project b')
          end
        end

        describe 'under a project' do
          specify 'belong to the project even without indents' do
            doc = parse "project:\n- task"
            expect(doc['project']).to be_parent_of('task')
          end
        end
      end

      describe 'multiple indents and outdents:' do
        let(:doc) do
          parse "project a:
                 \t- task x
                 \t\t- subtask of x
                 \t- task y
                 \t\t- subtask of y
                 project b:"
        end

        specify 'subtasks are children of tasks' do
          expect(doc['project a']['task x']).to be_parent_of('subtask of x')
          expect(doc['project a']['task y']).to be_parent_of('subtask of y')
        end

        describe 'outdenting by one level' do
          it "means the entry is a sibling of the preceding entry's parent" do
            expect(doc['project a']).to be_parent_of('task y')
          end
        end

        describe 'outdenting by more than one level' do
          it 'should identify the correct parent' do
            expect(doc).to be_parent_of('project b')
          end
        end

      end

      RSpec::Matchers.define :be_parent_of do |child_text|
        match do |parent|
          child = parent[child_text]
          !child.nil? && child.parent == parent
        end
      end

      def parse(document_text)
        parser.parse(lines(document_text))
      end

      def lines(string)
        string.gsub(/^ */, '').each_line
      end

    end

    describe '#strip_leave_indents:' do

      it 'strips line terminators' do
        expect(Parser.strip_leave_indents "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces' do
        expect(Parser.strip_leave_indents '  spacious  ').to eql 'spacious'
      end

      it 'preservs leading tabs' do
        expect(Parser.strip_leave_indents "\tstill indented!").to eql "\tstill indented!"
      end

    end

  end
end
