module TaskpaperUtils
  class Document
    (include EntryContainer).for_children_of_type :project, :task, :note

    def parent
      nil
    end

    def document
      self
    end

    def type
      :document
    end

  end
end
