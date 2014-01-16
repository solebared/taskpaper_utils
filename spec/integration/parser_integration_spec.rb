require 'spec_helper'

module TaskpaperUtils
  describe Parser, 'integration:' do
    include ParsingHelpers

    describe 'a simple document' do

      let(:project_a) { document['Project A'] }
      let(:document) do
        parse_doc(
          "Project A:
           - task one
           \t- subtask
           - task two @priority(1)
           a note
           \t- subtask of a note
           Project B:")
      end

      it 'contains projects' do
        expect(document).to have(2).projects
        expect(document.projects.map(&:text)).to eq ['Project A', 'Project B']
      end

      it 'contains tasks within projects' do
        expect(project_a).to have(2).tasks
        expect(project_a.tasks.map(&:text)).to eq ['task one', 'task two']
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

      describe 'tags' do

        it 'recognizes tags' do
          expect(project_a['task two'].tag?(:priority)).to be_true
        end

        it 'allows filtering by tag' do
          expect(document.tagged(:priority, '1')).to eq [project_a['task two']]
        end
      end
    end

    describe 'a document with notes and tasks outside of projects' do

      let(:document) do
        parse_doc(
          "a note
           - a task
           another note
           a project:
           - with a task")
      end

      it 'adopts the unowned entries' do
        expect(document).to have(4).entries
        expect(document.notes.map(&:text)).to eq ['a note', 'another note']
        expect(document).to have(1).tasks
        expect(document).to have(1).projects
      end

    end
  end
end
