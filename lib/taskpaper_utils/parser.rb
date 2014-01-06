module TaskpaperUtils

  # Parses a taskpaper formated document (accepted as an Enumerable)
  # Produces an object graph rooted at {Document}
  #
  # @api private
  module Parser

    TAG_ATOM = /@(\w+)(?:\((.+?)\))?/

    def self.strip_leave_indents(str)
      str.rstrip.sub(/\A */, '')
    end

    def self.create_entry(raw_text)
      text, trailing_tags = Parser.split_text_and_trailing_tags(raw_text.strip)
      type_class = Parser.identify_type(text)
      text = type_class::Identifier.strip(text)
      type_class.new(raw_text, text, trailing_tags)
    end

    def self.identify_type(text)
      Task::Identifier.accepts(text) || Project::Identifier.accepts(text) || Note
    end

    def self.parse_tags(line)
      line.scan(TAG_ATOM)
    end

    def self.parse(enum)
      document = Document.new
      enum.reduce(document) do |previous, line|
        EntryParser.parse_entry(strip_leave_indents(line), previous)
      end
      document
    end

    def self.split_text_and_trailing_tags(str)
      if match = /( #{TAG_ATOM})+\Z/.match(str)
        [match.pre_match, match[0]]
      else
        [str, '']
      end
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
