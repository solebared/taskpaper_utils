require './lib/taskpaper_tools'
require 'tempfile'

module TaskpaperTools
  describe TaskpaperTools, "integration:" do

    describe 'parsing and immediately saving the parsed object graph' do

      it 'results in a new file identical to the original' do
        # since the new file is based on the object graph, this serves as a good
        # integration test - anything we either don't parse or serialize correctly
        # will result in differing files
        document = TaskpaperTools.parse('spec/fixtures/exemplar.taskpaper')
        Dir::Tmpname.create('taskpaper_tools_integration_spec-') do |new_file|
          begin
            document.save(new_file)
            expect(File.read('spec/fixtures/exemplar.taskpaper')).to eql(File.read(new_file))
          ensure
            File.delete(new_file) if File.exist?(new_file)
          end
        end
      end


    end
  end
end
