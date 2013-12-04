require 'spec_helper'

module TaskpaperTools
  describe Project do

    describe '#text' do
      it 'strips trailing colon' do
        expect(Project.new('Project:').text).to eql 'Project'
      end
    end

  end
end
