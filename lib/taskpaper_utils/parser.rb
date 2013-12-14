require 'taskpaper_utils/entry'

module TaskpaperUtils
  class Parser
    include StringHelpers

    def parse(enum)
      document = Document.new
      enum.reduce(document) do |previous, line|
        EntryPair.new(previous, create_entry(line)).nest.current
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
  end # class Parser

  EntryPair = Struct.new(:previous, :current) do

    def nest
      identify_parent.add_child(current)
      self
    end

    def identify_parent
      return previous if previous.type? :document
      case previous.indentation <=> current.indentation
      when -1 then previous
      when  0 then determine_parent_when_equally_indented
      when  1 then EntryPair.new(previous.parent, current).identify_parent
      end
    end

    def determine_parent_when_equally_indented
      if current.unindented
        return previous.document if current.type?(:project)
        return previous          if previous.type?(:project)
      end
      previous.parent
    end

  end # class EntryPair
end
