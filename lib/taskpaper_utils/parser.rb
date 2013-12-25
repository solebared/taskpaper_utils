require 'taskpaper_utils/entry'

module TaskpaperUtils
  class Parser
    include StringHelpers

    def parse(enum)
      document = @current = Document.new
      enum.each do |line|
        @preceding, @current = @current, create_entry(line)
        identify_parent.add_child(@current)
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

    def identify_parent
      parent_if_preceding_is_document ||
      parent_if_preceding_less_indented ||
      parent_if_preceding_equally_indented ||
      parent_if_preceding_more_indented
    end

    def parent_if_preceding_is_document
      @preceding if @preceding.type? :document
    end

    def parent_if_preceding_less_indented
      @preceding if @preceding.indentation < @current.indentation
    end

    def parent_if_preceding_equally_indented
      if @preceding.indentation == @current.indentation
        parent_if_unindented_project ||
        parent_if_unindented_child_of_a_project ||
        @preceding.parent
      end
    end

    def parent_if_preceding_more_indented
      if @preceding.indentation > @current.indentation
        @preceding = @preceding.parent
        identify_parent   # recurse
      end
    end

    def parent_if_unindented_project
      @preceding.document if @current.unindented && @current.type?(:project)
    end

    def parent_if_unindented_child_of_a_project
      @preceding if @current.unindented && @preceding.type?(:project)
    end

  end
end
