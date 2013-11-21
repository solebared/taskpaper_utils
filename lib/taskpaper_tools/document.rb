module TaskpaperTools

  class Document
    EntryContainer
      .include_into(self)
      .generate_readers_for_children_of_type :project, :task, :note

    def parent
      nil
    end

    def document
      self
    end

    def to_s
      "==Document=="
    end
  end
end
