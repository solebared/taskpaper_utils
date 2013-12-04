require "spec_helper"

module TaskpaperTools
  describe Task do

    describe '#text' do
      it 'strips leading dash' do
        expect(Task.new(  "- task").text).to eql 'task'
      end
      it 'strips leading tab as well' do
        expect(Task.new("\t- task").text).to eql 'task'
      end
    end

    it 'aliases #tasks as #subtasks' do
      task = Task.new('- task')
      expect {
        task.add_child(Task.new("\t- subtask"))
      }.to change{ 
        task.subtasks.size
      }.by(1)
    end

  end
end
