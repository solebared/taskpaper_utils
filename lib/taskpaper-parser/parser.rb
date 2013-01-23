module TaskpaperParser
  class Parser

    def parse filepath
      projects = []
      File.foreach filepath do |line|
        line.chomp!
        projects << line if line =~ /:$/ unless line =~ /^(\s*)?-/
      end
      projects
    end

    def clean line
      line.rstrip.sub /^ */, ''
    end

    def indents line
      line[/\A\t*/].size
    end
  end
end
