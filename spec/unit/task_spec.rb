require 'spec_helper'

module TaskpaperUtils
  describe Task do
    include ParsingHelpers

    let(:task)    { new_entry('- task') }
    let(:subtask) { new_entry("\t- subtask") }

    specify 'identifier strips leading dash' do
      expect(Task::Identifier.strip('- task')).to eql 'task'
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
