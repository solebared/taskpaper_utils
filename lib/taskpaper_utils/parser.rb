module TaskpaperUtils

  # Parses a taskpaper formated document (accepted as an Enumerable)
  # Produces an object graph rooted at {Document}
  #
  # @api private
  module Parser

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
        EntryParser.parse_entry(strip_leave_indents(line), previous)
      end
      document
    end

    private

    # Responsible for parsing a single entry (line), and identifying its parent
    class EntryParser

      def self.parse_entry(raw_text, previous)
        new(raw_text)
          .create_entry
          .connect_to_parent(previous)
          .entry
      end

      attr_reader :entry

      def initialize(line)
        @raw_text = line
      end

      def create_entry
        @entry = Parser.create_entry(@raw_text)
        self
      end

      def connect_to_parent(previous_entry)
        @preceding = previous_entry
        identify_parent.add_child(@entry)
        self
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
