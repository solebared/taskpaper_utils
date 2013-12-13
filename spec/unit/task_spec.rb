require 'spec_helper'

module TaskpaperUtils
  describe Task do

    let(:task)    { Task.new('- task') }
    let(:subtask) { Task.new("\t- subtask") }

    describe '#text' do
      it 'strips leading dash' do
        expect(task.text).to eql 'task'
      end
      it 'strips leading tab as well' do
        expect(subtask.text).to eql 'subtask'
      end
    end

    it 'aliases #tasks as #subtasks' do
      task.add_child(subtask)
      expect(task.subtasks).to eql(task.tasks)
    end

    it 'is self aware' do
      expect(task.type).to equal(:task)
    end

  end
end
