module TaskpaperUtils

  # Container for {Entry} objects.
  #
  # Groups methods included into {Entry} and {Document} and provides most
  # of the public API for working with taskpaper objects.
  module EntryContainer

    # Class methods mixed into host when EntryContainer is included
    #
    # @api private
    module Generators
      def contains_children_of_type(*types)
        types.each do |type|
          define_method("#{type.to_s}s") { children_of_type type }
        end
      end
    end

    # @api private
    def self.included(klass)
      klass.extend EntryContainer::Generators
    end

    # @return [Array<Entry>] All contained entries
    def children
      @children ||= []
    end

    # Adds an entry to the container
    #
    # @param [Entry]
    # @return [Entry] the added entry.
    def add_child(entry)
      children << entry
      entry.parent = self
      entry
    end

    # Yields the whole subtree of raw text (starting at this entry) to the
    # block passed in.  First yields own raw_text (if it exists) and then
    # calls #dump an any children, resulting in the block being called
    # 0 to (children.size + 1) times.
    #
    # @yield [String] the raw text of this entry as well as the raw text of
    #   any of its children correctly indented.
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
    #   document['a project']['another']   # returns the second Task
    #
    # @param text [String] of the entry to be found without any
    #   type identifiers such as `- ` for tasks and `:` for projects
    def [](text)
      children.detect { |child| child.matches?(text) }
    end

    # @param (see #type?)
    # @return [Array] Children of the specified type
    #
    # @api private
    def children_of_type(entry_type)
      children.select { |child| child.type?(entry_type) }
    end

    # @param of [:project, :task, :note]
    # @return whether this Entry is of the specified type
    def type?(of)
      type == of
    end
  end
end
