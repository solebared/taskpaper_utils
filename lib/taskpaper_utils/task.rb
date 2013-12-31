module TaskpaperUtils

  # Represents a single task
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
