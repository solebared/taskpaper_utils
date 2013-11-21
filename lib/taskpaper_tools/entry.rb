module TaskpaperTools

  class Entry
    EntryContainer
      .include_into(self)
      .generate_readers_for_children_of_type :task, :note

    attr_accessor :parent
    attr_reader   :raw_text

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

      def initialize(raw_text)
        @raw_text = raw_text
      end

  end
end
