require './lib/taskpaper_tools/parser'

#todo: put this in TaskpaperTools module
describe TaskpaperTools::Parser do

  let(:parser) { TaskpaperTools::Parser.new }

  describe '#parse' do

    describe 'returned object graph' do
      let(:text) { <<-TEXT
                      Project A:
                      \t- task one
                      \t\t- subtask
                      \t- task two
                      Project B:
                      \tnote
                      \t\t- subtask of a note
                      TEXT
      }
      let(:projects) { parser.parse text }

      it 'contains projects' do
        expect(projects.size).to eql 2
        expect(projects).to include("Project A")
        expect(projects).to include("Project B")
      end

      pending 'contains tasks within projects' do
        project_a = projects["Project A"]
        expect(project_a.tasks.size).to eql 2
      end

    end
  end

end
