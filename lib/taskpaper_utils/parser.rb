require 'taskpaper_utils/entry'

module TaskpaperUtils
  class Parser
    include StringHelpers

    def parse_file(path)
      File.open(path) { |file| parse file }
    end

    def parse(enum)
      document = Document.new
      enum.reduce(document) do |preceding_entry, line|
        create_entry(line).tap do |current_entry|
          connect_to_parent(current_entry, preceding_entry)
        end
      end
      document
    end

    def create_entry(line)
      raw_text = strip_leave_indents(line)
      ( case
        when raw_text =~ /\A(\s*)?-/  then Task
        when raw_text.end_with?(':')  then Project
        else                               Note
        end
      ).new raw_text
    end

    def connect_to_parent(current_entry, preceding_entry)
      find_parent_of(current_entry, preceding_entry).add_child(current_entry)
    end

    def find_parent_of(current_entry, preceding_entry)
      return preceding_entry if preceding_entry.type? :document
      case preceding_entry.indentation <=> current_entry.indentation
      when -1
        preceding_entry
      when  0
        determine_parent_of_equally_indented_entries(current_entry, preceding_entry)
      when  1
        find_parent_of(current_entry, preceding_entry.parent)
      end
    end

    def determine_parent_of_equally_indented_entries(current_entry, preceding_entry)
      if preceding_entry.unindented
        return preceding_entry.document if current_entry.type?(:project)
        return preceding_entry          if preceding_entry.type?(:project)
      end
      preceding_entry.parent
    end

  end
end
