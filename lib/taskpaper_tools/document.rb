module TaskpaperTools

  class Document
    include EntryContainer
    extend  EntryContainer::ClassMethods

    generate_readers_for_children_of_type :project, :task, :note

    def find_parent_of other
      self  # **I** am your father... you know this to be true
    end

    def document
      self
    end

    def to_s
      "==Document=="
    end
  end
end
