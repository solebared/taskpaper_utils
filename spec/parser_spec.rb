require './lib/taskpaper_tools/parser'

#todo: put this in TaskpaperTools module
describe TaskpaperTools::Parser do

  let(:parser) { TaskpaperTools::Parser.new }

  describe '#parse' do

    describe 'returned object graph' do
      #todo: remove indents for first set of tasks
      let(:text) { <<-TEXT.split("\n")
                      Project A:
                      \t- task one
                      \t\t- subtask
                      \t- task two
                      Project B:
                      \tnote
                      \t\t- subtask of a note
                      TEXT
      }
      let(:document) { parser.parse text }
      let(:projects) { document.children }  #todo: change this to .projects

      it 'contains projects' do
        expect(projects.size).to eql 2
        expect(projects.first.text).to eql("Project A")
        expect(projects.last.text ).to eql("Project B")
      end

      it 'contains tasks within projects' do
        project_a = projects.first
        expect(project_a.children.size).to eql 2
        #todo: change this to project_a.tasks
      end

    end
  end

end
