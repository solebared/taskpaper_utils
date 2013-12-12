require 'spec_helper'

module TaskpaperUtils
  describe IndentAware do

    IndentAwareClass = Struct.new(:raw_text) do
      include IndentAware
    end

    def host(raw_text)
      IndentAwareClass.new(raw_text)
    end

    describe '#indentation' do
      it 'calculates indentation based on the number of leading tabs' do
        expect(host('No indents on this line').indentation).to eql 0
        expect(host("\tOne on this line     ").indentation).to eql 1
        expect(host("\t\tTwo on this line   ").indentation).to eql 2
        expect(host("\t\t  Two here as well ").indentation).to eql 2
      end
    end

    describe '#undindented' do
      it 'identifies text that is unindented' do
        expect(host('Not indented').unindented).to be_true
        expect(host("\t\tindented").unindented).to be_false
      end
    end

  end
end
