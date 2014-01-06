require 'spec_helper'

module TaskpaperUtils
  describe Project do
    include EntryHelpers

    let(:project) { new_entry('Project:') }

    describe 'strip identifier' do
      it 'strips trailing colon' do
        expect(Project::Identifier.strip('Project:')).to eql 'Project'
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
