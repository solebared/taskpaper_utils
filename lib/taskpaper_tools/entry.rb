module TaskpaperTools

  # Internal: Groups methods included into Entry and Document
  module EntryContainer

    # Lazy initializes an array.  Provided only for convenience; the @children
    # ivar is not referenced, only the method
    #
    # Returns an object that responds to #<< and #each.
    def children() 
      @children ||= []
    end

    # Entry - We expect to hold Entry objects, however anything that responds
    #         to #yield_text(&block) will work
    def add_child entry
      children << entry
    end

    # Yields own text to the block and then recurses over children,
    # effectively yielding the whole sub-tree of text rooted from this instance
    def yield_text &block
      yield text if respond_to? :text
      children.each { |child| child.yield_text &block }
    end
  end

  class Entry
    include EntryContainer

    attr_reader :parent
    attr_reader :text

    def self.create text, preceding_entry
      ( case
        when text =~ /\A(\s*)?-/  then Task
        when text.end_with?(':')  then Project
        else                           Note
        end
      ).new text, preceding_entry
    end

    def document
      parent.document
    end

    # Internal
    def indents
      text[/\A\t*/].size
    end

    # Internal
    def to_s
      text
    end

    protected

    def find_parent_of later_entry
      if indents < later_entry.indents
        self
      elsif indents == later_entry.indents
        select_parent_of_equally_indented_entry later_entry
      else
        parent.find_parent_of later_entry
      end
    end

    def select_parent_of_equally_indented_entry later_entry
      if indents == 0
        return document if later_entry.is_a?(Project)
        return self if self.is_a?(Project)
      end
      return parent
    end

    private

    def initialize(raw_text, preceding_entry)
      @text = clean(raw_text)
      @parent = preceding_entry.find_parent_of(self)
      @parent.add_child self
    end

    def clean raw_text
      raw_text.rstrip.sub(/\A */, '')
    end
  end

  class Project < Entry
  end

  class Task < Entry
  end

  class Note < Entry
  end

  class Document
    include EntryContainer

    def find_parent_of other
      self  # **I** am your father... you know this to be true (i have no ancestors)
    end

    def document
      self
    end

    def to_s
      "==Document=="
    end
  end
end
