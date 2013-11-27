require "spec_helper"

module TaskpaperTools
  describe Entry do
    include EntrySpecHelpers

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
