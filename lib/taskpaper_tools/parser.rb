require 'taskpaper_tools/line_item'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse io
      #todo: this could be better and in any case, rethink what is returned
      projects = Hash.new
      preceding_item = RootItem.new
      io.lines do |line|
        item = LineItem.new(line, preceding_item)
        if item.project? 
          projects[item.text] = item
        end
        preceding_item = item
      end
      projects
    end

  end
end
