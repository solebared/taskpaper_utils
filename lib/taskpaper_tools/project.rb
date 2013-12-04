module TaskpaperTools
  class Project < Entry
    def text
      raw_text.sub(/:$/, '')
    end
  end
end
