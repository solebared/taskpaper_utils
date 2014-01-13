require 'spec_helper'

module TaskpaperUtils
  describe RawEntry do
    include ParsingHelpers

    describe '#initialize' do

      describe 'text stripping' do

        let(:raw) { raw_entry("\t- an entry") }

        it 'strips the identifier (-) and indents ' do
          expect(raw.text).to eq('an entry')
        end

        it 'leaves the raw_text alone' do
          expect(raw.raw_text).to eq("\t- an entry")
        end
      end

      describe 'tags' do

        let(:tagged) { raw_entry('- an @entry with @trailing(tag)') }

        it 'separates out the title portion of the raw text (aka text)' do
          expect(tagged.text).to eq('an @entry with')
        end

        it 'captures the trailing tags after the title' do
          expect(tagged.trailing_tags).to eq(' @trailing(tag)')
        end

        it 'initializes with both inline and trailing tags' do
          expect(tagged.tags).to eq([['entry', nil], %w(trailing tag)])
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
            expect('project: @with @trailing(tags)').to be_identified_as_a(:project)
          end
        end

        RSpec::Matchers.define :be_identified_as_a do |type|
          match do |raw_text|
            @actual = raw_entry(raw_text).type
            @actual == type
          end

          failure_message_for_should do |raw_text|
            "Expected '#{raw_text}' to be identified as a '#{type}', not '#{@actual}'"
          end
        end

      end
    end

    describe '#split_text_and_trailing_tags' do

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
          @actual = raw_entry(actual).split_text_and_trailing_tags
          @expected = [text, @tags]
          @actual == @expected
        end

        failure_message_for_should do
          "Expected\n#{expected}, but was\n#{actual}"
        end

      end

    end

    describe '#parse_tags' do

      it 'returns an empty array if there are no tags' do
        expect(raw_entry('no tags').parse_tags).to be_empty
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
          @actual = raw_entry(string).parse_tags
          @actual == array_of_tags
        end

        failure_message_for_should do |string|
          "Expected '#{string}' to parse into tags\n#{array_of_tags} but got\n#{@actual}"
        end
      end

    end

    describe '#strip_identifier' do

      it 'strips leading dash and indents from tasks' do
        expect(raw_entry("\t\t- todo").strip_identifier).to eq('todo')
      end

      it 'strips trailing colon from project' do
        expect(raw_entry('things:').strip_identifier).to eq('things')
      end

      it 'just returns the input text for a note' do
        expect(raw_entry('any text').strip_identifier).to eq('any text')
      end

    end
  end
end
