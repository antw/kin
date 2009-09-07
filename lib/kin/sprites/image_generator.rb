module Kin
  module Sprites
    ##
    # Responsible for taking source icon files and creating a sprite.
    #
    class ImageGenerator
      IconNotReadable = Class.new(SpriteError)
      TargetNotWriteable = Class.new(SpriteError)

      ##
      # Creates a new Generator instance.
      #
      # @param [IconSet] set
      #   An IconSet instance.
      # @param [String] source_dir
      #   A path to the directory in which the source files reside.
      #
      # @api public
      #
      def initialize(set, source_dir)
        @set, @source_dir = set, source_dir
      end

      ##
      # Uses RMagick to create a transparent PNG containing the individual
      # icons as a sprite.
      #
      # If a file already exists at the given path it will be overwritten.
      #
      # @param [String] path
      #   The path at which to save the sprite.
      #
      # @raise [Kin::Sprites::ImageGenerator::IconNotReadable]
      #   Raised when an icon could not be found.
      #
      # @raise [Kin::Sprites::ImageGenerator::TargetNotWriteable]
      #   Raised when RMagick couldn't save the image because the target path
      #   was not writeable.
      #
      # @raise [Magick::ImageMagickError]
      #   Raised if some other error occured with RMagick.
      #
      # @api public
      #
      def save(path)
        list = @set.inject(Magick::ImageList.new) do |m, icon|
          m << Magick::Image.read(File.join(@source_dir, "#{icon}.png"))[0]
        end

        # RMagick uses instance_eval, @set isn't available in the block below.
        set_length = @set.length

        montage = list.montage do
          # Transparent background.
          self.background_color = '#FFF0'
          # Each icon is 16x16 with 12 pixels of top & bottom padding = 16x40.
          self.geometry = Magick::Geometry.new(16, 16, 0, 12)
          self.tile = Magick::Geometry.new(1, set_length)
        end

        # Remove the blank space from both the top and bottom of the image.
        montage.crop!(0, 12, 0, (40 * set_length) - 24)
        montage.write("PNG32:#{path}")
      rescue Magick::ImageMagickError => ex
        # Nicely rescue and re-raise if the target directory wasn't writable,
        # or if one of the icon files could not be opened.
        case ex.message
          when /Permission denied/ then raise TargetNotWriteable, ex.message
          when /unable to open/    then raise IconNotReadable, ex.message
          else                          raise ex
        end
      end
    end # ImageGenerator
  end # Sprites
end # Kin
