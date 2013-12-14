%w(version helpers indent_aware entry_container
   document entry project task note parser).each do |lib|
  require "taskpaper_utils/#{lib}"
end

module TaskpaperUtils

  def self.parse(path)
    File.open(path) { |file| Parser.new.parse(file) }
  end

  def self.save(document, path)
    File.open(path, 'w') do |file|
      document.dump { |raw_text| file.puts(raw_text) }
    end
  end

end
