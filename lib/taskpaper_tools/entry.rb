module TaskpaperTools

  #todo: Tom-doc
  # Mixers must implement:
  # - a #text method representing how the Entry (w/o any children) would appear in a .taskpaper file
  # - optionally, an overriding implementation of #children to return anything that responds to
  #   #<< and #each
  module EntryContainer

    # Provided as a convenience.  The module does not depend on the @children ivar.
    # Override to use a different var name or implementation.  Must respond to #<< and #each.
    def children() 
      @children ||= []
    end

    # Any entry added must respond to #serialize(collector)
    def add_child entry
      children << entry
    end

    # todo: is collector the right name?
    def serialize collector
      collector << "#{text}\n" if respond_to? :text
      children.each { |child| child.serialize collector }
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
