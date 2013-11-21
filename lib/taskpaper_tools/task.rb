module TaskpaperTools
  class Task < Entry
    alias :subtasks :tasks
    def text
      raw_text.strip.sub /^- /, ''
    end
  end
end

