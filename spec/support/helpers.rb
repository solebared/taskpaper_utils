module EntryHelpers

  def new_entry(raw_text)
    TaskpaperUtils::Parser.create_entry(raw_text)
  end

end
