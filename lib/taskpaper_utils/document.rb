module TaskpaperUtils
  # Root object representing a taskpaper formated document.
  # Contains nested {Entry} objects that represent projects, tasks and notes.
  class Document
    (include EntryContainer).for_children_of_type :project, :task, :note

    # @return [nil] nil since it is the root object
    #
    # @api private
    def parent
      nil
    end

    # @return [Document] self
    #
    # @api private
    def document
      self
    end

    # @return [Symbol] :document
    #
    # @api private
    def type
      :document
    end

  end
end
