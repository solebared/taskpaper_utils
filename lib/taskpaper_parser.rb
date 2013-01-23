require "taskpaper-parser/version"
require "taskpaper-parser/parser"

module TaskpaperParser
  def self.parse filepath
    Parser.new.parse filepath
  end
end
