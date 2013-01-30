require "taskpaper_tools/version"
require "taskpaper_tools/parser"

module TaskpaperTools
  def self.parse file
    Parser.new.parse_file file
  end
  def self.save document, path
    File.open(path, 'w') do |file|
      document.yield_raw_text { |raw_text| file.puts raw_text }
    end
  end
end
