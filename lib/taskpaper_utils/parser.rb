module TaskpaperUtils

  # Parses a taskpaper formated document (accepted as an Enumerable)
  # Produces an object graph rooted at {Document}
  #
  # @api private
  class Parser

    def self.strip_leave_indents(str)
      str.rstrip.sub(/\A */, '')
    end

    def self.create_entry(raw_text)
      ( case
        when raw_text =~ /\A(\s*)?-/  then Task
        when raw_text.end_with?(':')  then Project
        else                               Note
        end
      ).new(raw_text)
    end

    def self.parse_tags(line)
      line.scan(/@(\w+)(?:\((.+?)\))?/)
    end

    def self.parse(enum)
      document = Document.new
      enum.reduce(document) do |previous, line|
        parse_entry(line, previous)
      end
      document
    end

    def self.parse_entry(line, previous)
      entry = create_entry(strip_leave_indents(line))
      raw_entry = ParentHound.new(previous, entry)
      raw_entry.identify_parent.add_child(entry)
      entry
    end

    # Walks back up the previously parsed entries to determine the right parent.
    #
    # @api private
    class ParentHound

      attr_reader :entry

      def initialize(previous_entry, entry)
        @preceding = previous_entry
        @entry = entry
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
        @preceding if @preceding.indentation < @entry.indentation
      end

      def parent_if_preceding_equally_indented
        if @preceding.indentation == @entry.indentation
          parent_if_unindented_project ||
          parent_if_unindented_child_of_a_project ||
          @preceding.parent
        end
      end

      def parent_if_preceding_more_indented
        if @preceding.indentation > @entry.indentation
          @preceding = @preceding.parent
          identify_parent   # recurse
        end
      end

      def parent_if_unindented_project
        @preceding.document if @entry.unindented && @entry.type?(:project)
      end

      def parent_if_unindented_child_of_a_project
        @preceding if @entry.unindented && @preceding.type?(:project)
      end
    end
  end
end
