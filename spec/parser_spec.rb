require "spec_helper"

module TaskpaperTools
  describe Parser do

    let(:parser) { Parser.new }

    describe '#clean:' do
      it 'strips line terminators' do
        expect(parser.clean "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(parser.clean "  spacious  ").to eql "spacious"
      end

      it 'preservs tabs' do
        expect(parser.clean "\tstill indented!").to eql "\tstill indented!"
      end
    end

  end
end
