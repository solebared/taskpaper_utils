require "./lib/taskpaper_tools/line_item.rb"

module TaskpaperTools
  describe LineItem do

    describe '#type' do
      it 'recognizes a project line' do
        item = LineItem.new 'A project:'
        expect(item).to be_project
      end
    end

    describe '#text:' do
      it 'strips line terminators' do
        item = LineItem.new      "a line\n"
        expect(item.text).to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        item = LineItem.new    "  \tspacious  "
        expect(item.text).to eql "\tspacious"
      end

      it 'strips colon from project lines' do
        item = LineItem.new "Project:"
        expect(item.text).to eql "Project"
      end
    end

    describe '#indents' do
      it 'calculates the number of indents for a given line from the number of leading tabs' do
        expect(LineItem.new("No indents on this line"  ).indents).to eql 0
        expect(LineItem.new("\tOne on this line"       ).indents).to eql 1
        expect(LineItem.new("\t\tTwo on this line"     ).indents).to eql 2
        expect(LineItem.new("\t\t  Two here as well"   ).indents).to eql 2
        expect(LineItem.new(" \tLeading spaces ignored").indents).to eql 1
      end
    end
  end
end
