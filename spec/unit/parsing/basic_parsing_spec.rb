require 'spec_helper'

# todo: pull out of module
module TaskpaperUtils
  describe 'Basic parsing' do
    include SpecHelpers

    # todo: collapse describe block
    describe 'a simple document' do

      let(:document) do
        parse(
          "Project A:
           - task one
           \t- subtask
           - task two
           a note
           \t- subtask of a note
           Project B:")
      end

      let(:project_a) { document['Project A'] }

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

    end
  end
end
