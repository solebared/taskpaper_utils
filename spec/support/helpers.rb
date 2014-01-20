module ParsingHelpers

  def parser
    @parser ||= TaskpaperUtils::Parser.new
  end

  def new_entry(raw_text)
    TaskpaperUtils::Entry.parse(raw_text)
  end

  def raw_entry(raw_text)
    TaskpaperUtils::RawEntry.new(raw_text)
  end

  def parse_doc(document_text)
    parser.parse(lines(document_text))
  end

  def lines(string)
    string.gsub(/^ +/, '').lines
  end

end

# todo: eliminate ParsingHelpers
module SpecHelpers

  def parse(document_text)
    TaskpaperUtils.parse(lines(document_text))
  end

  def parse_entry(line)
    parse(line).first
  end

  # todo: duplicated in ParsingHelpers
  # todo: move this functionality into Parser?
  def lines(string)
    string.gsub(/^ +/, '').lines
  end

end
