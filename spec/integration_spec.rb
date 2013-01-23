require './lib/taskpaper_parser'

describe TaskpaperParser do

  describe '#parse' do
    let(:projects) { TaskpaperParser.parse('spec/fixtures/exemplar.taskpaper') }

    describe 'identifies projects' do

      it 'excludes lines containing a colon that are actually tasks' do
        expect(projects).to_not include("- this is not a project even though it ends with a colon:")
      end
    end
  end
end
