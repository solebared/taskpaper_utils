require 'taskpaper_tools/line_item'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse io
      projects = []
      io.lines do |line|
        item = LineItem.new(line)
        if item.project? 
          projects << item.text
        end
      end
      projects
    end

  end
end
