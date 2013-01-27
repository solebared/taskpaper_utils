require 'taskpaper_tools/entry'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse enum
      document = Document.new
      enum.reduce(document) { |preceding_entry, line| Entry.create(line, preceding_entry) }
      document
    end

  end
end
