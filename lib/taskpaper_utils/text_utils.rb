module TaskpaperUtils
  module TextUtils
    def strip_leave_indents(raw_text)
      raw_text.rstrip.sub(/\A */, '')
    end
  end
end
