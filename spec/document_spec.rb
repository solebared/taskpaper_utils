require 'spec_helper'

module TaskpaperTools
  describe Document do

    let(:document) { Document.new }

    it 'generates getters for projects, notes and tasks' do
      expect(document.public_methods).to include(:projects, :notes, :tasks)
    end

    it 'returns self from #document' do
      expect(document.document).to equal document
    end

    it 'has no parent' do
      expect(document.parent).to be_nil
    end
  end
end
