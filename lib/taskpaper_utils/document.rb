module TaskpaperUtils
  # Root object representing a taskpaper formated document
  # May contain {Project}, {Task} and {Note} objects
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
