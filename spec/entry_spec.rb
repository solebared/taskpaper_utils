require 'spec_helper'

module TaskpaperUtils
  describe Entry do

    let(:entry) { Entry.new('any entry') }

    it 'generates getters for notes and tasks' do
      expect(entry.public_methods).to include(:notes, :tasks)
    end

    it 'delgates #document to its parent' do
      entry.parent = double('parent-entry')
      entry.parent.should_receive('document')
      entry.document
    end
  end
end
