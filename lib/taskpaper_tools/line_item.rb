module TaskpaperTools
  class LineItem

    def initialize text
      @text = clean(text)
    end

    def project?
      @text.end_with?(':') && @text !~ /^(\s*)?-/
    end

    def text
      project? ? @text.chomp(':') : @text
    end

    def indents
      @text[/\A\t*/].size
    end

    private

    def clean(text = nil)
      text.rstrip.sub /^ */, ''
    end
  end
end
