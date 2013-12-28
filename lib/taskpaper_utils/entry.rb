module TaskpaperUtils
  class Entry
    (include EntryContainer).for_children_of_type :task, :note
    include IndentAware

    attr_accessor :parent
    attr_reader   :raw_text

    def initialize(raw_text)
      @raw_text = raw_text
    end

    def document
      parent.document
    end

    # helpful for troubleshooting, but not otherwise needed
    # def inspect
      # "#<#{self.class.name}:#{@raw_text}>"
    # end
  end
end
