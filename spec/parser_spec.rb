require './lib/taskpaper-parser/parser'

describe TaskpaperParser::Parser do

  let(:parser) { TaskpaperParser::Parser.new }

  describe '#clean' do
    it 'strips line terminators' do
      expect(parser.clean "a line\n").to eql 'a line'
    end

    it 'strips leading and trailing spaces while preserving tabs' do
      expect(parser.clean "  \tspacious  ").to eql "\tspacious"
    end
  end

  describe '#indents' do
    it 'Calculates the number of indents for a given line from the number of leading tabs' do
      expect(parser.indents ("No indents on this line" )).to eql 0
      expect(parser.indents ("\tOne on this line"      )).to eql 1
      expect(parser.indents ("\t\tTwo on this line"    )).to eql 2
      expect(parser.indents ("\t\t  Two here as well"  )).to eql 2
      expect(parser.indents (" \tLeading spaces not ok")).to eql 0
    end
  end

end
