require 'taskpaper_tools/entry'

module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse enum
      document = Document.new
      enum.reduce(document) do |preceding_entry, line| 
        create_entry(clean(line)).tap do |current_entry|
          find_parent_of(current_entry, preceding_entry).add_child(current_entry)
        end
      end
      document
    end

    def create_entry raw_text
      ( case
        when raw_text =~ /\A(\s*)?-/  then Task
        when raw_text.end_with?(':')  then Project
        else                               Note
        end
      ).new raw_text
    end

    def clean raw_text
      raw_text.rstrip.sub(/\A */, '')
    end

    def find_parent_of(current_entry, preceding_entry)
      return preceding_entry unless preceding_entry.parent

      if preceding_entry.indents < current_entry.indents
        preceding_entry
      elsif preceding_entry.indents == current_entry.indents
        select_parent_of_equally_indented_entry(current_entry, preceding_entry)
      else
        find_parent_of(current_entry, preceding_entry.parent)
      end
    end

    def select_parent_of_equally_indented_entry current_entry, preceding_entry
      if preceding_entry.indents == 0
        return preceding_entry.document if current_entry.is_a?(Project)
        return preceding_entry if preceding_entry.is_a?(Project)
      end
      return preceding_entry.parent
    end
  end
end
