require 'taskpaper_tools/line_item'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse enum
      document = Document.new
      enum.reduce(document) { |preceding_item, line| LineItem.new(line, preceding_item) }
      document
    end

  end
end
