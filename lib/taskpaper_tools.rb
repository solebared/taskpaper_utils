require "taskpaper_tools/version"
require "taskpaper_tools/parser"

module TaskpaperTools
  def self.parse file
    Parser.new.parse_file file
  end
  def self.save document, path
    File.open(path, 'w') do |to_file|
      document.serialize to_file
    end
  end
end
