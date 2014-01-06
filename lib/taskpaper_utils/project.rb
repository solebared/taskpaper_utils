module TaskpaperUtils

  # Represents a project
  class Project < Entry

    TYPE = :project

    alias_method :title, :text

    # @api private
    class Identifier

      def self.accepts(str)
        str.end_with?(':') ? Project : false
      end

      def self.strip(str)
        str.sub(/:\Z/, '')
      end

    end
  end
end
