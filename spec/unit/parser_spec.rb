require 'spec_helper'

module TaskpaperUtils
  describe Parser do
    include EntryHelpers

    describe '::create_entry' do

      let(:entry) { new_entry("\t- an @entry") }

      it 'strips the identifier (-) and indents ' do
        expect(entry.text_with_trailing_tags).to eq('an @entry')
      end

      it 'separates out the title portion of the raw text (aka text)' do
        expect(entry.text).to eq('an')
      end

      describe 'project with trailing tags' do
        it 'strips trailing tags before identifying type' do
          entry = new_entry("project: @with @trailing(tags)")
          expect(entry.type).to equal(:project)
        end
      end
    end

    describe 'type identification' do

      describe 'recognizes basic entry types' do
        specify('a project') { expect('a project:').to be_identified_as_a(:project) }
        specify('a task   ') { expect('- a task  ').to be_identified_as_a(:task) }
        specify('a note   ') { expect('a note    ').to be_identified_as_a(:note) }
      end

      describe 'edge cases:' do
        it 'recognizes tasks that end with a colon' do
          expect('- task or project?:').to be_identified_as_a(:task)
        end

        it 'recognizes projects with trailing tags' do
          # see '::create_entry spec'
        end
      end

      RSpec::Matchers.define :be_identified_as_a do |type|
        match do |raw_text|
          @text = raw_text
          @actual = Parser.identify_type(raw_text)::TYPE
          @actual == type
        end

        failure_message_for_should do
          "Expected '#{@text}' to be identified as a '#{type}', not '#{@actual}'"
        end
      end

    end

    describe 'parent indentification' do

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
        Parser.parse(lines(document_text))
      end

      def lines(string)
        string.gsub(/^ */, '').each_line
      end

    end

    describe '::strip_leave_indents:' do

      it 'strips line terminators' do
        expect(strip_leave_indents("a line\n")).to eq('a line')
      end

      it 'strips leading and trailing spaces' do
        expect(strip_leave_indents('  spacious  ')).to eq('spacious')
      end

      it 'preserves leading tabs' do
        expect(strip_leave_indents("\tstill indented!")).to eq("\tstill indented!")
      end

      def strip_leave_indents(str)
        Parser.strip_leave_indents(str)
      end

    end

    describe '::split_text_and_trailing_tags' do

      it 'returns [input string, blank] when it has no tags' do
        expect('no tags').to be_split_into_text('no tags').with_trailing_tags('')
      end

      it 'strips a single trailing tag' do
        expect('one @tag').to be_split_into_text('one').with_trailing_tags(' @tag')
      end

      it 'strips multiple trailing tags' do
        expect('1 @2 @3') .to be_split_into_text('1').with_trailing_tags(' @2 @3')
      end

      it 'does not strip tags in between text' do
        expect('in @btw een').to be_split_into_text('in @btw een').with_trailing_tags('')
      end

      it 'considers the first tag to be text if the line is only tags' do
        expect('@all(words) @are(tags)')
          .to be_split_into_text('@all(words)').with_trailing_tags(' @are(tags)')
      end

      RSpec::Matchers.define :be_split_into_text do |text|

        chain(:with_trailing_tags) do |tags|
          @tags = tags
        end

        match do |actual|
          @actual = Parser.split_text_and_trailing_tags(actual)
          @expected = [text, @tags]
          @actual == @expected
        end

        failure_message_for_should do
          "Expected\n#{expected}, but was\n#{actual}"
        end

      end

    end

    describe '::parse_tags' do

      it 'returns an empty array if there are no tags' do
        expect(Parser.parse_tags('no tags')).to be_empty
      end

      it 'parses a tag at the end of the line' do
        expect('last @word').to be_parsed_into_tags(['word', nil])
      end

      it 'parses a tag in the middle of a line' do
        expect('before @and after').to be_parsed_into_tags(['and', nil])
      end

      it 'allows tags to have a value' do
        expect('@tag(with value)').to be_parsed_into_tags(['tag', 'with value'])
      end

      it 'parses multiple tags' do
        expect('numbers: @one(1) and @two(2) but not three)')
          .to be_parsed_into_tags(%w(one 1), %w(two 2))
      end

      RSpec::Matchers.define :be_parsed_into_tags do |*array_of_tags|
        match do |string|
          @actual = Parser.parse_tags(string)
          @actual == array_of_tags
        end

        failure_message_for_should do |string|
          "Expected '#{string}' to parse into tags\n#{array_of_tags} but got\n#{@actual}"
        end
      end

    end
  end
end
