require './lib/taskpaper_tools'

module TaskpaperTools
  describe TaskpaperTools, "integration:" do

    describe '#parse' do
      let(:document) { TaskpaperTools.parse('spec/fixtures/exemplar.taskpaper') }

      describe Document do

        it 'contains some projects' do
          #projects.each { |text, project| p text; p project.children }
          #todo: document.projects
          expect(document.children.size).to be > 1
        end

        pending 'identifies all projects' do
          expect(document.children.size).to eql 3
        end

      end
    end
  end
end
