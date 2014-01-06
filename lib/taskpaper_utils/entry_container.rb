module TaskpaperUtils

  # Container for Entry objects (anything that responds to #type,
  # #dump and #text (see {#add_child})
  #
  # Groups methods included into Entry and Document and provides most
  # of the public API for working with taskpaper objects.
  module EntryContainer

    # Class methods mixed into host when EntryContainer is included
    #
    # @api private
    module Generators
      def for_children_of_type(*types)
        types.each do |type|
          define_method("#{type.to_s}s") { children_of_type type }
        end
      end
    end

    # @api private
    def self.included(klass)
      klass.extend EntryContainer::Generators
    end

    # @return [Array] All contained entries
    def children
      @children ||= []
    end

    # Adds an entry to the container
    #
    # @param [#text, #type, #dump]
    # @return the added entry
    def add_child(entry)
      children << entry
      entry.parent = self
      entry
    end

    # @yield Provides the raw text of the entry as well as the text of
    #   any of its children correctly indented.  Used to get the whole
    #   tree of raw_text rooted at this point.
    def dump(&block)
      yield raw_text if respond_to?(:raw_text)
      children.each { |child| child.dump(&block) }
    end

    # Locate a child entry by its text.
    #
    # @example
    #   # a project:
    #   #   - a task
    #   #   - another
    #   document['a project'][another]   # returns the second Task
    #
    # @param [String] the text of the entry to be found without any
    #   type identifiers such as `- ` for tasks and `:` for projects
    def [](search)
      children.detect do |child|
        child.text == search || child.text_with_trailing_tags == search
      end
    end

    # @param (see #type?)
    # @return [Array] Children of the specified type
    def children_of_type(entry_type)
      children.select { |child| child.type?(entry_type) }
    end

    # @param [:project, :task, :note]
    # @return Whether this Entry is of the specified type
    def type?(of)
      type == of
    end
  end
end
