module TaskpaperUtils
  class Task < Entry

    alias_method :subtasks, :tasks

    def text
      raw_text.strip.sub(/^- /, '')
    end

    def type
      :task
    end

  end
end
