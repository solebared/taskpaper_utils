require 'spec_helper'

describe 'Elements parsed from a single entry' do
  include SpecHelpers

  describe 'text' do

    it 'strips leading dash and indents from tasks' do
      expect(parse_entry("\t\t- task").text).to eq('task')
    end

    it 'strips trailing colon from project' do
      expect(parse_entry('things:').text).to eq('things')
    end

    it 'just returns the input text for a note' do
      expect(parse_entry('any text').text).to eq('any text')
    end

  end

  describe 'trailing tags' do
    # todo: is trailing tags an implementation detail?

    it 'parses text and a single trailing tag' do
      expect('one @tag').to be_parsed_as_text('one').and_trailing_tags(' @tag')
    end

    it 'returns an empty string when no trailing tags are present' do
      expect('no tags').to be_parsed_as_text('no tags').and_trailing_tags('')
    end

    it 'parses text and multiple trailing tags' do
      expect('1 @2 @3').to be_parsed_as_text('1').and_trailing_tags(' @2 @3')
    end

    it 'considers tags in between text to be part of the text' do
      expect('in @btw een').to be_parsed_as_text('in @btw een').and_trailing_tags('')
    end

    it 'considers the first tag to be part of text if the line is only tags' do
      expect('@all(words) @are(tags)')
      .to be_parsed_as_text('@all(words)').and_trailing_tags(' @are(tags)')
    end

    RSpec::Matchers.define :be_parsed_as_text do |text|

      chain(:and_trailing_tags) do |tags|
        @tags = tags
      end

      match do |string|
        @entry = parse_entry(string)
        @entry.text == text && @entry.trailing_tags == @tags
      end

      failure_message_for_should do |string|
        <<-END
        Expected text:#{text} and trailing tags:#{@tags}
         but got text:#{@entry.text} and trailing tags:#{@entry.trailing_tags}
        END
      end
    end
  end
end
