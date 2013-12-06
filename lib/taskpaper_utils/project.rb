module TaskpaperUtils
  class Project < Entry
    def text
      raw_text.sub(/:$/, '')
    end

    alias_method :title, :text
  end
end
