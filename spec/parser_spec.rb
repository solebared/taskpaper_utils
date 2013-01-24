require './lib/taskpaper_tools/parser'

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

      pending 'contains subtasks within projects' do
        project_a = projects["Project A"]
        expect(project_a.tasks.size).to eql 2
      end

    end

    describe 'nesting' do
      pending 'it assigns sub-items to their parents' do
      end
    end
  end

  describe 'utility methods' do

    describe '#clean' do
      it 'strips line terminators' do
        expect(parser.clean "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(parser.clean "  \tspacious  ").to eql "\tspacious"
      end
    end

    describe '#indents' do
      it 'calculates the number of indents for a given line from the number of leading tabs' do
        expect(parser.indents ("No indents on this line" )).to eql 0
        expect(parser.indents ("\tOne on this line"      )).to eql 1
        expect(parser.indents ("\t\tTwo on this line"    )).to eql 2
        expect(parser.indents ("\t\t  Two here as well"  )).to eql 2
        expect(parser.indents (" \tLeading spaces not ok")).to eql 0
      end
    end
  end

end
