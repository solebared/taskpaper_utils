require 'spec_helper'

describe 'Tag parsing' do
  include SpecHelpers

  describe 'tags' do

    let(:document) do
      parse("project:
             - task @priority(1)")
    end

    it 'recognizes tags' do
      expect(document['project']['task'].tag?(:priority)).to be_true
    end

    it 'allows filtering by tag' do
      pending 'move this to document specs'
      expect(document.tagged(:priority, '1')).to eq [project_a['task two']]
    end

  end
end
