module TaskpaperUtils

  # Represents a single entry, i.e: a project, task or note
  class Entry
    include IndentAware
    extend Forwardable

    # !method tasks
    #   @return [Array<Entry>] any children of type :task
    # !method notes
    #   @return [Array<Entry>] any children of type :note
    (include EntryContainer).for_children_of_type :task, :note

    # (see #tasks)
    alias_method :subtasks, :tasks

    # !attribute [r] raw_text
    #   @return [String] the raw single line of text for this entry in taskpaper format
    # !attribute [r] type
    #   @return [Symbol<:project, :task, :note>]
    # !attribute [r] text
    #   @return [String] the text of the entry without tabs,
    #     identifiers (such as '-' or ':') or trailing tags
    # !attribute [r] trailing_tags
    #   @return [String] any tags that follow the text or an empty string ('') otherwise.
    #     Tags mixed in with the text are not considered trailing tags.
    #     Includes a preceding space if trailing tags exist.
    #   @example
    #     entry = Entry.parse("- task with a @tag mixed in @and @trailing @tags")
    #     entry.text  # => "task with a @tag mixed in"
    #     entry.trailing_tags   # => " @and @trailing @tags"
    def_delegators :@raw, :raw_text, :type, :text, :trailing_tags

    # @return [Entry] to which this one belongs
    attr_reader :parent

    # @api private
    attr_writer :parent

    # @param [[String, String]] the set of tags to initialize this entry with
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
    #   @see #trailing_tags
    def text_with_trailing_tags
      text + trailing_tags
    end

    # @param [String]
    # @return [Boolean] whether the string provided matches the entry text.
    #   Tests against the text with and without trailing tags (@see !trailing_tags).
    def matches?(str)
      text == str || text_with_trailing_tags == str
    end

    # Convenience accessor for the root document
    # @return [Document]
    def document
      parent.document
    end

    # @param String the name of the tag to lookup
    # @return [nil] if this entry is not tagged with the given name
    # @return [true] if its tagged with no value
    # @return [String] the value of the tag if a value exists (eg: @tag(value))
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
