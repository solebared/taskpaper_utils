module TaskpaperUtils

  # Parses a taskpaper formated document (accepted as an Enumerable)
  # Produces an object graph rooted at {Document}
  #
  # @api private
  class Parser

    TAG_ATOM = /@(\w+)(?:\((.+?)\))?/

    def self.strip_leave_indents(str)
      str.rstrip.sub(/\A */, '')
    end

    def self.create_entry(raw_text)
      text, trailing_tags = split_text_and_trailing_tags(raw_text.strip)
      type_class = identify_type(text)
      text = type_class::Identifier.strip(text)
      type_class.new(raw_text, text, trailing_tags)
    end

    def self.identify_type(text)
      Task::Identifier.accepts(text) || Project::Identifier.accepts(text) || Note
    end

    def self.parse_tags(line)
      line.scan(TAG_ATOM)
    end

    def self.split_text_and_trailing_tags(str)
      if matched = /( #{TAG_ATOM})+\Z/.match(str) # rubocop:disable AssignmentInCondition
        [matched.pre_match, matched[0]]
      else
        [str, '']
      end
    end

    def parse(enum)
      @current = document = Document.new
      enum.each { |line| parse_line(line) }
      document
    end

    def parse_line(line)
      @preceding = @current
      @current = Parser.create_entry(line)
      identify_parent.add_child(@current)
      @current
    end

    private

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
