module TaskpaperUtils

  # Represents a single line of free-form notes
  class Note < Entry

    def text
      raw_text
    end

    def type
      :note
    end

  end
end
