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
      collector << "#{text}\n" unless text.nil?   # root Document should not add any text
      children.each { |child| child.serialize collector }
    end

  end

  class Entry
    include EntryContainer

    attr_reader :parent
    attr_reader :text

    def initialize(raw_text, preceding_entry)
      @text = clean(raw_text)
      @parent = determine_parent(preceding_entry)
      @parent.add_child self
    end

    #todo: these should not be public?
    def task?;     @text =~ /\A(\s*)?-/            end
    def project?;  @text.end_with?(':') && !task?  end
    def note?;     not (task? or project?)         end

    def determine_parent preceding_entry
      if preceding_entry.indented_less_than(self)
        preceding_entry
      else
        preceding_entry.find_common_ancestor self
      end
    end

    def indented_less_than other
      indents < other.indents
    end

    #todo: this is only public for testing
    def indents
      text[/\A\t*/].size
    end

    def to_s
      "#{text} <- #{parent.text}"
    end

    def find_common_ancestor other
      if indents == other.indents
        #todo: this is specific to  a project
        if self.project? && !other.project?
          return self 
        else
          return parent
        end
      end
      parent.find_common_ancestor other
    end

    def clean raw_text
      raw_text.rstrip.sub(/\A */, '')
    end

    private   :determine_parent, :clean
    protected :find_common_ancestor, :indented_less_than

  end

  class Document
    include EntryContainer

    def indented_less_than other
      true  #Document is always the least indented
    end

    def text
      nil
    end

    def to_s
      #todo: append filepath
      "Document (*path*) "
    end

    def save path
      File.open(path, 'w') do |to_file|
        serialize to_file
      end
    end
  end
end
