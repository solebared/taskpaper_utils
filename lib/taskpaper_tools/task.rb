module TaskpaperTools
  class Task < Entry
    alias_method :subtasks, :tasks
    def text
      raw_text.strip.sub(/^- /, '')
    end
  end
end
