module TaskpaperTools
  module TextUtils
    def indents(entry)
      entry.raw_text[/\A\t*/].size
    end

    def unindented(entry)
      indents(entry) == 0
    end

    def compare_indents(lhs, rhs)
      indents(lhs) <=> indents(rhs)
    end

    def strip_leave_indents(raw_text)
      raw_text.rstrip.sub(/\A */, '')
    end
  end
end
