require 'spec_helper'

module TaskpaperUtils
  describe Project do

    let(:project) { Project.new('Project') }

    describe '#text' do
      it 'strips trailing colon' do
        expect(project.text).to eql 'Project'
      end
    end

    describe '#title' do
      it 'is an alias for #text' do
        expect(project.title).to eql project.text
      end
    end

    it 'is self aware' do
      expect(project.type).to equal(:project)
    end

  end
end
