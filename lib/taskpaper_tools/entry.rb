module TaskpaperTools

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
        else                               Note
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

    private

      def initialize(raw_text, preceding_entry)
        @raw_text = raw_text
        @parent = preceding_entry.find_parent_of(self)
        @parent.add_child self
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
  end
end
