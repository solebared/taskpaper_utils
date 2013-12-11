module TaskpaperUtils

  # Expects host object to provide a #raw_text method
  module IndentAware

    def indentation
      raw_text[/\A\t*/].size
    end

    def unindented
      indentation == 0
    end

  end
end
