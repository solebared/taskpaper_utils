require './lib/taskpaper_tools/parser'

module TaskpaperTools
  describe Parser do

    let(:parser) { Parser.new }

    describe '#parse' do

      #todo: spec Document
      #it "contains tasks and notes that don't belong to a projcect"

      describe 'returned object graph' do
        let(:text) { "Project A:
                      - task one
                      \t- subtask
                      - task two
                      Project B:
                      \tnote
                      \t\t- subtask of a note".gsub(/^ +/, '').lines
        }
        let(:document) { parser.parse text }
        let(:projects) { document.children }  #todo: change this to .projects

        it 'contains projects' do
          expect(projects.size).to eql 2
          expect(projects.first.text).to eql("Project A:")
          expect(projects.last.text ).to eql("Project B:")
        end

        it 'contains tasks within projects' do
          project_a = projects.first
          expect(project_a.children.size).to eql 2
          #todo: change this to project_a.tasks
        end
      end
    end

    describe '#clean:' do
      it 'strips line terminators' do
        expect(parser.clean "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(parser.clean "  \tspacious  ").to eql "\tspacious"
      end
    end

  end
end
