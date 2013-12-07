require 'spec_helper'

module TaskpaperUtils
  describe Project do

    describe '#text' do
      it 'strips trailing colon' do
        expect(Project.new('Project:').text).to eql 'Project'
      end
    end

    describe '#title' do
      it 'is an alias for #text' do
        project = Project.new('This text is my title:')
        expect(project.title).to eql project.text
      end
    end

  end
end
