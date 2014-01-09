%w(version
   indent_aware
   entry_container
   document
   raw_entry
   entry
   parser
).each do |lib|
  require "taskpaper_utils/#{lib}"
end

# Provides an API for parsing and working with taskpaper formated documents.
# @see README
module TaskpaperUtils

  # Parse the taskpaper formated document
  #
  # @param path [String] of file to parse
  # @return [Document]
  def self.parse(path)
    File.open(path) { |file| Parser.new.parse(file) }
  end

  # Serialize a {Document} to a file in taskpaper format
  #
  # @param document [Document] to serialize
  # @param path [String] of file to serialize to (will be overwritten)
  def self.save(document, path)
    File.open(path, 'w') do |file|
      document.dump { |raw_text| file.puts(raw_text) }
    end
  end

end
