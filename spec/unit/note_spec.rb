require 'spec_helper'

module TaskpaperUtils
  describe Note do
    include ParsingHelpers

    let(:note) { new_entry('any text') }

    describe 'Identifier' do
      specify 'strip just returns the raw text' do
        expect(Note::Identifier.strip('any text')).to eq('any text')
      end
    end

    it 'is self aware' do
      expect(note.type).to equal(:note)
    end

  end
end
