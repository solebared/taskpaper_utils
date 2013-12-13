module TaskpaperUtils
  class Note < Entry

    def text
      raw_text
    end

    def type
      :note
    end

  end
end
