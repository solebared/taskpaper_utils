require './lib/taskpaper_tools'

describe TaskpaperTools, "integration:" do

  describe '#parse' do
    let(:projects) { TaskpaperTools.parse('spec/fixtures/exemplar.taskpaper') }

    describe 'projects' do

      it 'identifies some projects' do
        #projects.each { |text, project| p text; p project.children }
        expect(projects.size).to be > 1
      end

      pending 'identifies all projects' do
        expect(projects.size).to eql 3
      end

      it 'excludes lines containing a colon that are actually tasks' do
        expect(projects).to_not include("- this is not a project even though it ends with a colon:")
      end
    end
  end
end
