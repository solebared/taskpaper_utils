module TaskpaperTools

  class LineItem
    attr_accessor :parent
    attr_accessor :children

    def initialize(text, preceding_item)
      @text = clean(text)
      @children = []
      determine_parent(preceding_item)
      @parent.children << self
    end

    def task?;     @text =~ /\A(\s*)?-/            end
    def project?;  @text.end_with?(':') && !task?  end
    def note?;     not (task? or project?)         end

    def determine_parent preceding_item
      if indents > preceding_item.indents
        @parent = preceding_item
      else
        @parent = preceding_item.find_common_ancestor self
      end
    end

    def text
      project? ? @text.chomp(':') : @text
    end

    def indents
      @text[/\A\t*/].size
    end

    def to_s
      "#{text} <- #{parent.text}"
    end

    protected

    def find_common_ancestor other
      if indents == other.indents
        #todo: refactor for clarity
        if self.project? && !other.project?
          return self 
        else
          return parent
        end
      end
      parent.find_common_ancestor other
    end

    private

    def clean(text = nil)
      text.rstrip.sub /\A */, ''
    end
  end

  # Represents the phantom line preceding the first line and is also
  # the root container for all items in the file
  class RootItem < LineItem
    def initialize
      @children = []
    end
    def indents
      -1
    end
    def text
      "** RootItem **"
    end
    def to_s
      text
    end
  end
end
