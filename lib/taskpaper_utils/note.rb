module TaskpaperUtils

  # Represents a single line of free-form notes
  class Note < Entry

    TYPE = :note

    # @api private
    class Identifier
      def self.strip(str)
        str
      end
    end

  end
end
