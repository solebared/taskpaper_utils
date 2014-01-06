module TaskpaperUtils

  # Represents a single task
  class Task < Entry

    TYPE = :task

    alias_method :subtasks, :tasks

    # @api private
    class Identifier

      def self.accepts(str)
        str =~ /\A(\s*)?-/ ? Task : false
      end

      def self.strip(str)
        str.sub(/\A- /, '')
      end

    end
  end
end
