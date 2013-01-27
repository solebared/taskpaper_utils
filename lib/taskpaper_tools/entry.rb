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

    #todo: this is only public for testing
    def indents
      text[/\A\t*/].size
    end

    def to_s
      "#{text} <- #{parent.text}"
    end

    protected

    #todo: try one more time to name this method
    def find_shared_ancestor_of other
      if indents < other.indents
        self
      elsif indents == other.indents
        select_parent_of_equally_indent_entry other
      else
        parent.find_shared_ancestor_of other
      end
    end

    def select_parent_of_equally_indent_entry other
      # for tasks and notes, this is easy
      # if two entries have equal indents, then they have the same parent
      parent
    end

    private

    def initialize(raw_text, preceding_entry)
      @text = clean(raw_text)
      @parent = preceding_entry.find_shared_ancestor_of(self)
      @parent.add_child self
    end

    def clean raw_text
      raw_text.rstrip.sub(/\A */, '')
    end
  end

  class Project < Entry
    def select_parent_of_equally_indent_entry other
      # i own equally indented tasks and notes but not projects
      other.is_a?(Project) ? parent : self 
    end
  end

  class Task < Entry
  end

  class Note < Entry
  end

  class Document
    include EntryContainer

    def find_shared_ancestor_of other
      self  # **I** am your father... you know this to be true ('cos i have no ancestors)
    end

    def to_s
      #todo: append filepath
      "Document (*path*) "
    end
  end
end
