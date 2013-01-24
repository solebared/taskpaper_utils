module TaskpaperTools
  class Parser

    def parse_file path
      File.open(path) { |file| parse file }
    end

    def parse io
      projects = []
      io.lines do |line|
        line = clean(line)
        if line.end_with?(':') && line !~ /^(\s*)?-/ 
          projects << line.chomp(':')
        end
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
