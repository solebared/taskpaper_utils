module TaskpaperTools

  # Internal: Groups methods included into Entry and Document
  module EntryContainer

    module ClassMethods
      def generate_readers_for_children_of_type *types
        types.each do |type|
          define_method("#{type.to_s}s") { children_of_type type }
        end
      end
    end

    # Lazy initializes an array.  Provided only for convenience; the @children
    # ivar is not referenced, only the method
    #
    # Returns an object that responds to #<< and #each.
    def children
      @children ||= []
    end

    # Entry - We expect to hold Entry objects, however anything that responds
    #         to #yield_raw_text(&block) will work
    def add_child entry
      children << entry
    end

    # Yields own raw text to the block and then recurses over children,
    # effectively yielding the whole sub-tree of text rooted at this instance
    def yield_raw_text &block
      yield raw_text if respond_to? :raw_text
      children.each { |child| child.yield_raw_text &block }
    end

    # Internal
    #
    # Symbol - symbolic representation of one of the Entry subclasses
    def children_of_type entry_type
      entry_class = TaskpaperTools.const_get(entry_type.capitalize)
      children.select { |child| child.is_a? entry_class }
    end
  end

  class Entry
    include EntryContainer
    extend  EntryContainer::ClassMethods

    generate_readers_for_children_of_type :task, :note

    attr_reader :parent
    attr_reader :raw_text

    def self.create raw_text, preceding_entry
      ( case
        when raw_text =~ /\A(\s*)?-/  then Task
        when raw_text.end_with?(':')  then Project
        else                           Note
        end
      ).new raw_text, preceding_entry
    end

    def document
      parent.document
    end

    # Internal
    def indents
      raw_text[/\A\t*/].size
    end

    # Internal
    def to_s
      raw_text
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
      @raw_text = raw_text
      @parent = preceding_entry.find_parent_of(self)
      @parent.add_child self
    end
  end

  class Project < Entry
    def text
      raw_text.sub /:$/, ''
    end
  end

  class Task < Entry
    alias :subtasks :tasks
    def text
      raw_text.strip.sub /^- /, ''
    end
  end

  class Note < Entry
    def text
      raw_text
    end
  end

  class Document
    include EntryContainer
    extend  EntryContainer::ClassMethods

    generate_readers_for_children_of_type :project, :task, :note

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
