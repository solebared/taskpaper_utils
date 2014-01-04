require 'spec_helper'

module TaskpaperUtils
  describe Entry do

    let(:entry) { Entry.new('any entry') }

    it 'generates getters for notes and tasks' do
      expect(entry.public_methods).to include(:notes, :tasks)
    end

    it 'delegates #document to its parent' do
      entry.parent = double('parent-entry')
      entry.parent.should_receive('document')
      entry.document
    end

    describe 'tags' do

      describe 'initializing and retrieving tags' do

        before do
          entry.tags = [['empty', nil], %w(with value)]
        end

        it 'returns nil if the tag does not exist' do
          expect(entry.tag('nope')).to be_nil
        end

        it 'returns true if the tag exists without a value' do
          expect(entry.tag('empty')).to equal(true)
        end

        it 'returns value if the tag exists with a value' do
          expect(entry.tag('with')).to eql('value')
        end

      end
    end
  end
end
