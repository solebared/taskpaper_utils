require 'spec_helper'

module TaskpaperUtils
  describe Task do

    describe '#text' do
      it 'strips leading dash' do
        expect(Task.new('- task').text).to eql 'task'
      end
      it 'strips leading tab as well' do
        expect(Task.new("\t- task").text).to eql 'task'
      end
    end

    it 'aliases #tasks as #subtasks' do
      task = Task.new('- task')
      task.add_child(Task.new("\t- subtask"))
      expect(task.subtasks).to eql(task.tasks)
    end

  end
end
