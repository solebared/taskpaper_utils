module TaskpaperUtils
  # @abstract class representing a single line entry,
  #   implemented in {Project}, {Task} and {Note}
  class Entry
    (include EntryContainer).for_children_of_type :task, :note
    include IndentAware

    # The entry to which this one belongs
    attr_reader :parent

    # @api private
    attr_writer :parent

    # @api private
    attr_reader   :raw_text

    # @param [[String, String]] the set of tags to initialize this entry with
    #
    # @api private
    attr_writer :tags

    # @api private
    def initialize(raw_text)
      @raw_text = raw_text
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

    # helpful for troubleshooting, but not otherwise needed
    # def inspect
      # "#<#{self.class.name}:#{@raw_text}>"
    # end
  end
end
