require 'taskpaper_tools/entry'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse enum
      document = Document.new
      enum.reduce(document) do |preceding_entry, line| 
        Entry.create(clean(line), preceding_entry) 
      end
      document
    end

    def clean raw_text
      raw_text.rstrip.sub(/\A */, '')
    end
  end
end
