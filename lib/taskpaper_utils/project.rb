module TaskpaperUtils

  # Represents a project
  class Project < Entry

    def text
      raw_text.sub(/:$/, '')
    end

    alias_method :title, :text

    def type
      :project
    end

  end
end
