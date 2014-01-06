module TaskpaperUtils
  # @abstract class representing a single line entry,
  #   implemented in {Project}, {Task} and {Note}
  class Entry
    (include EntryContainer).for_children_of_type :task, :note
    include IndentAware

    # The entry to which this one belongs
    attr_reader :parent

    # Text of the entry without tabs, identifiers (such as '-' or ':')
    # or trailing tags
    attr_reader :text

    # @api private
    attr_writer :parent

    # @api private
    attr_reader   :raw_text

    # @param [[String, String]] the set of tags to initialize this entry with
    #
    # @api private
    attr_writer :tags

    # @api private
    def initialize(raw_text, text, trailing_tags)
      @raw_text, @text, @trailing_tags = raw_text, text, trailing_tags
    end

    # @return [String] Text of the entry with trailing tags (no tabs or identifiers)
    def text_with_trailing_tags
      @text + @trailing_tags
    end

    # Convenience accessor for the root document
    def document
      parent.document
    end

    # @param String the name of the tag to lookup
    # @return nil if this entry is not tagged with the given name
    # @return true if its tagged with no value
    # @return String the value of the tag if a value exists (eg: @tag(value))
    def tag(name)
      tag, value = @tags.detect { |tag, value| tag == name }
      tag && (value || true)
    end

    def type
      self.class::TYPE
    end

    # helpful for troubleshooting, but not otherwise needed
    # def inspect
      # "#<#{self.class.name}:#{@raw_text}>"
    # end
  end
end
