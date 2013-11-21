module TaskpaperTools

  # Internal: Groups methods included into Entry and Document
  module EntryContainer

    def self.include_into(klass)
      klass.instance_eval do
        include EntryContainer
        def self.generate_readers_for_children_of_type *types
          types.each do |type|
            define_method("#{type.to_s}s") { children_of_type type }
          end
        end
      end
      klass
    end

    # Lazy initializes an array.  Provided only for convenience; the @children
    # ivar is not referenced, only the method
    #
    # Returns an object that responds to #<< and #each.
    def children
      @children ||= []
    end

    # Entry - We expect to hold Entry objects, however anything that responds
    #         to #yield_raw_text(&block) and #type?(:document|:project|:task|:note) will work
    def add_child entry
      children << entry
      entry.parent = self
    end

    # Yields own raw text to the block and then recurses over children,
    # effectively yielding the whole sub-tree of text rooted at this instance
    def yield_raw_text &block
      yield raw_text if respond_to? :raw_text
      children.each { |child| child.yield_raw_text(&block) }
    end

    # Internal
    #
    # Symbol - symbolic representation of one of the Entry subclasses
    def children_of_type entry_type
      children.select { |child| child.type? entry_type }
    end

    def type?(of)
      self.class.name.split('::').last.to_sym.downcase == of
    end
  end
end

