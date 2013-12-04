require 'spec_helper'

module TaskpaperTools

  describe TextUtils do
    include TextUtils

    def entry(raw_text)
      # anything that provides a raw_text methd
      double(raw_text: raw_text)
    end

    describe '#indents' do
      it 'calculates the number of indents for a given line from the number of leading tabs' do
        expect(indents(entry('No indents on this line'))).to eql 0
        expect(indents(entry("\tOne on this line"     ))).to eql 1
        expect(indents(entry("\t\tTwo on this line"   ))).to eql 2
        expect(indents(entry("\t\t  Two here as well" ))).to eql 2
      end
    end

    describe '#undindented' do
      it 'identifies text that is unindented' do
        expect(unindented(entry('Not indented'))).to be_true
        expect(unindented(entry("\t\tindented"))).to be_false
      end
    end

    describe '#compare_indents' do
      it 'returns 0 if both entries have equal indents' do
        expect(compare_indents(entry('a'), entry('b'))).to eql(0)
      end

      it 'returns -1 if the first entry is indented less than the second' do
        expect(compare_indents(entry('a'), entry("\tb"))).to eql(-1)
      end

      it 'returns +1 if the first entry is indented more than the second' do
        expect(compare_indents(entry("\ta"), entry('b'))).to eql(1)
      end
    end

    describe '#strip_leave_indents:' do
      it 'strips line terminators' do
        expect(strip_leave_indents "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces' do
        expect(strip_leave_indents '  spacious  ').to eql 'spacious'
      end

      it 'preservs leading tabs' do
        expect(strip_leave_indents "\tstill indented!").to eql "\tstill indented!"
      end
    end

  end
end
