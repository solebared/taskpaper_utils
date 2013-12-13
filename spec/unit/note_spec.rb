require 'spec_helper'

module TaskpaperUtils
  describe Note do

    let(:note) { Note.new('any text') }

    describe '#text' do
      it 'returns the raw text' do
        expect(note.text).to eql 'any text'
      end
    end

    it 'is self aware' do
      expect(note.type).to equal(:note)
    end

  end
end
