require "taskpaper_tools/version"
require "taskpaper_tools/parser"

module TaskpaperTools
  def self.parse filepath
    Parser.new.parse_file filepath
  end
end
