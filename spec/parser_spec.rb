require './lib/taskpaper_tools/parser'

module TaskpaperTools
  describe Parser do

    let(:parser) { Parser.new }

    describe '#parse' do

      describe 'a simple document' do
        let(:document) { parser.parse(lines(
          "Project A:
           - task one
           \t- subtask
           - task two
           a note
           \t- subtask of a note
           Project B:"
        ))}
        let(:projects) { document.projects }

        it 'contains projects' do
          expect(projects.size).to eql 2
          expect(projects.map(&:text)).to eql ["Project A", "Project B"]
        end

        it 'contains tasks within projects' do
          project_a = projects.first
          expect(project_a.tasks.size).to eql 2
          expect(project_a.tasks.map(&:text)).to eql ["task one", "task two"]
        end

        it 'contains subtasks nested under tasks' do
          task_one = projects.first.tasks.first
          expect(task_one.subtasks.size).to eql 1
          expect(task_one.subtasks.first.text).to eql "subtask"
        end

        it 'contains notes within projects' do
          notes = projects.first.notes
          expect(notes.size).to eql 1
          expect(notes.first.text).to eql "a note"
        end
      end

      describe 'a document with notes and tasks outside of projects' do
        let(:document) { parser.parse(lines(
          "a note
           - a task
           another note
           a project:
           - with a task"
        ))}

        it 'adopts the unowned entries' do
          expect(document.children.size).to eql 4
          expect(document.notes.map(&:text)).to eql ['a note', 'another note']
          expect(document.tasks.size).to eql 1
          expect(document.projects.size).to eql 1
        end

      end

      def lines string
        string.gsub(/^ +/, '').lines
      end
    end

    describe '#clean:' do
      it 'strips line terminators' do
        expect(parser.clean "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces while preserving tabs' do
        expect(parser.clean "  spacious  ").to eql "spacious"
      end

      it 'preservs tabs' do
        expect(parser.clean "\tstill indented!").to eql "\tstill indented!"
      end
    end

  end
end
