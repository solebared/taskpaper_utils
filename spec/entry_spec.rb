require "spec_helper"

module TaskpaperTools
  describe Entry do
    include EntrySpecHelpers

    describe '#indents' do
      it 'calculates the number of indents for a given line from the number of leading tabs' do
        expect(entry("No indents on this line"  ).indents).to eql 0
        expect(entry("\tOne on this line"       ).indents).to eql 1
        expect(entry("\t\tTwo on this line"     ).indents).to eql 2
        expect(entry("\t\t  Two here as well"   ).indents).to eql 2
      end
    end

    describe 'type characteristics' do

      describe '#text' do

        specify 'Tasks strip leading tabs and dash' do
          expect(entry(  "- task").text).to eql 'task'
          expect(entry("\t- task").text).to eql 'task'
        end

        specify 'Projects strip trailing colon' do
          expect(entry("Project:").text).to eql 'Project'
        end
      end
    end

  end
end
