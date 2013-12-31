module TaskpaperUtils
  # @api private
  module StringHelpers
    def strip_leave_indents(str)
      str.rstrip.sub(/\A */, '')
    end
  end
end
