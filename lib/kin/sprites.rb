require 'rmagick'

module Kin
  ##
  # Takes 16x16 pixel icons and smushes them all together in to one sprite.
  # Not auto-loaded, so remember to require 'kin/sprites' if you need it.
  #
  module Sprites
    SpriteError = Class.new(StandardError)

    ##
    # A simple class which represents a list of icons (wrapper around an
    # array).
    #
    class IconSet
      include Enumerable

      ##
      # Creates a new IconSet instance.
      #
      # @param [Array<String>] icons
      #   An array of source icon files.
      #
      def initialize(icons)
        @icons = icons.uniq
      end

      ##
      # Returns the vertical offset of a given icon in a sprite.
      #
      # @param [String]
      #   The name of an icon which appears in the list.
      #
      # @return [Integer]
      #
      # @example
      #   list = IconSet.new(%w( one two three ))
      #   list.location_of('one')   # => 0
      #   list.location_of('two')   # => 40
      #   list.location_of('three') # => 80
      #
      # @raise [ArgumentError]
      #   Raises an ArgumentError if the given icon does not appear in the
      #   list.
      #
      def location_of(icon)
        unless @icons.include?(icon)
          raise ArgumentError, "Icon does not appear in the list: #{icon}"
        end

        @icons.index(icon) * 40
      end

      ##
      # Loops through, and yields, each icon in turn.
      #
      # @yield [String] The icon name.
      #
      def each
        @icons.each { |i| yield i }
      end

      ##
      # Returns the number of icons in this set.
      #
      # @return [Integer]
      #
      def length
        @icons.length
      end

      ##
      # Returns a slice of the set. Note: This returns a Set, not an IconSet.
      #
      # @param [Numeric, Range] slice
      #   The element or range of elements to return.
      #
      # @return [Set]
      #
      def [](*slice)
        @icons[*slice]
      end

      ##
      # Returns a hash for the icon list. Assuming the list contains the same
      # icons, and in the same order, the hash will always be the same.
      #
      # @return [String]
      #
      def hash
        Digest::SHA256.hexdigest(@icons.join("|"))
      end
    end # IconSet
  end # Sprites
end # Kin

sprites = File.expand_path(File.join(File.dirname(__FILE__), 'sprites'))

require File.join(sprites, 'image_generator')
require File.join(sprites, 'sass_generator')