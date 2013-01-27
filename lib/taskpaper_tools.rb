require "taskpaper_tools/version"
require "taskpaper_tools/parser"

module TaskpaperTools
  def self.parse file
    Parser.new.parse_file file
  end
end
