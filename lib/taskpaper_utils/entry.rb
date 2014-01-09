module TaskpaperUtils

  # Represents a single entry (project, task or note)
  class Entry
    extend Forwardable
    include IndentAware
    include EntryContainer

    # @macro contains_tasks
    # @macro contains_notes
    contains_children_of_type :task, :note

    # (see #tasks)
    alias_method :subtasks, :tasks

    # @!attribute [r] raw_text
    #   @return [String] the single line of raw text for this entry in taskpaper format
    # @!attribute [r] type
    #   @return [Symbol] the type of this entry, :project, :task, or :note
    # @!attribute [r] text
    #   @return [String] the text of the entry without tabs,
    #     identifiers (such as '-' or ':') or trailing tags
    # @!attribute [r] trailing_tags
    #   @return [String] any tags that follow the text or an empty string ('') otherwise.
    #     Tags mixed in with the text are not considered trailing tags.
    #     Includes a preceding space if trailing tags exist.
    #   @example
    #     entry = Entry.parse("- task with a @tag mixed in @and @trailing @tags")
    #     entry.text  # => "task with a @tag mixed in"
    #     entry.trailing_tags   # => " @and @trailing @tags"
    def_delegators :@raw, :raw_text, :type, :text, :trailing_tags

    # @return [Entry] parent {Entry} to which this one belongs
    attr_reader :parent

    # @api private
    attr_writer :parent

    # @param tags [[String, String]] the set of tags to initialize this entry with
    #
    # @api private
    attr_writer :tags

    # @api private
    def self.parse(raw_text)
      new(RawEntry.new(raw_text))
    end

    # @api private
    def initialize(raw_entry)
      @raw = raw_entry
    end

    # @return [String] Text of the entry with trailing tags included.
    #   Excludes tabs and identifiers.
    #   @see {#trailing_tags}
    def text_with_trailing_tags
      text + trailing_tags
    end

    # @param text_to_match [String]
    # @return [Boolean] whether the string provided matches the entry text.
    #   Tests against the text with and without trailing tags (see {#trailing_tags}).
    def matches?(str)
      text == str || text_with_trailing_tags == str
    end

    # Convenience accessor for the root document to which this {Entry} belongs
    # @return [Document]
    def document
      parent.document
    end

    # @param name [String] the name of the tag to lookup
    # @return [true] if this entry is tagged with no value (eg: @tag)
    # @return [String] the value of the tag if a value exists (eg: @tag(value))
    # @return [nil] if its not tagged with the given name
    def tag(name)
      tag, value = @tags.detect { |tag, value| tag == name }
      tag && (value || true)
    end

    # helpful for troubleshooting, but not otherwise needed
    # def inspect
      # "#<#{self.class.name}:#{@raw_text}>"
    # end
  end
end
