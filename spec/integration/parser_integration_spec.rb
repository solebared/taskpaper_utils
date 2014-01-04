require 'spec_helper'

module TaskpaperUtils
  describe Parser, 'integration:' do

    let(:parser) { Parser.new }

    describe 'a simple document' do
      let(:document) do
        parser.parse(lines(
          "Project A:
           - task one
           \t- subtask
           - task two
           a note
           \t- subtask of a note
           Project B:"
        ))
      end
      let(:project_a) { document['Project A'] }

      it 'contains projects' do
        expect(document).to have(2).projects
        expect(document.projects.map(&:text)).to eql ['Project A', 'Project B']
      end

      it 'contains tasks within projects' do
        expect(project_a).to have(2).tasks
        expect(project_a.tasks.map(&:text)).to eql ['task one', 'task two']
      end

      it 'contains subtasks nested under tasks' do
        task_one = project_a['task one']
        expect(task_one).to have(1).subtasks
        expect(task_one['subtask']).to_not be_nil
      end

      it 'contains notes within projects' do
        expect(project_a).to have(1).notes
        expect(project_a['a note']).to_not be_nil
      end
    end

    describe 'a document with notes and tasks outside of projects' do
      let(:document) do
        parser.parse(lines(
          "a note
           - a task
           another note
           a project:
           - with a task"
        ))
      end

      it 'adopts the unowned entries' do
        expect(document).to have(4).children
        expect(document.notes.map(&:text)).to eql ['a note', 'another note']
        expect(document).to have(1).tasks
        expect(document).to have(1).projects
      end

    end

    def lines(string)
      string.gsub(/^ +/, '').lines
    end
  end
end
