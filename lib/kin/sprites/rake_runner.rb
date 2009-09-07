require 'digest/sha2'

module Kin
  module Sprites
    ##
    # A Rake helper which generates all the sprites for a given application.
    #
    # RakeRunner expects a sprites.yml config file which defines the sprites
    # and the icons in each sprite. The contents of each sprites are hashed
    # and cached in a .hashes file (the the same directory as the saved
    # sprites) so that re-running the task won't result in them being
    # re-generated. See README for examples.
    #
    # Not auto-loaded by requiring either 'kin' or 'kin/sprites'; if you want
    # this Rake helper you need to require it explicitly.
    #
    class RakeRunner
      TEMPLATE = File.read(__FILE__).split(/^__END__/)[1]

      SetInfo = Struct.new(:name, :set, :skipped)

      ##
      # Creates a new Generator instance.
      #
      # @param [String] sprites_yml
      #   The path to the sprites.yml file which defines the sprites.
      # @param [String] sprites_dir
      #   The path to sprites directory, in which the generated sprites will
      #   be saved. The source icons will be assumed to be in a src/
      #   subdirectory.
      # @param [String] sass_partial
      #   The path where the SASS partial should be saved.
      #
      # @raise [SpriteError]
      #   Raised if the sprites.yml file wasn't at the specified path.
      #
      # @api public
      #
      def initialize(sprites_yml, sprites_dir, sass_partial)
        @sprites_yml  = sprites_yml
        @sprites_dir  = sprites_dir
        @sass_partial = sass_partial
        @source_dir   = File.join(@sprites_dir, 'src')
        @dot_hashes   = File.join(@sprites_dir, '.hashes')

        unless File.exists?(@sprites_yml)
          raise SpriteError,
            "sprites.yml not found; expected to be at: #{@sprites_yml}"
        end

        @sets = YAML.load(File.read(@sprites_yml)).map do |name, icons|
          SetInfo.new(name, Kin::Sprites::IconSet.new(icons), false)
        end

        # Sort the sets in alphanumeric order such that SASS partials don't
        # radically change when regenerated (since Ruby 1.8's hash is
        # unordered)
        @sets.sort! { |left, right| left.name <=> right.name }
      end

      ##
      # Generates the sprite images, and creates a _sprites.sass partial.
      #
      # @param [Boolean] force
      #   Regenerate sprite images even if the existing image contains the
      #   exact same icons as the new one will.
      #
      # @api public
      #
      def generate!(force = false)
        @sets.each do |set|
          generate_sprite!(set, force)
        end

        if @sets.any? { |set| not set.skipped }
          generate_sass!
          dump_hashes!
        end

        $stdout.puts
        $stdout.puts("All done.")
      end

      private # ==============================================================

      ##
      # Generates a single sprite.
      #
      # @api private
      #
      def generate_sprite!(setinfo, force)
        if requires_regenerating?(setinfo) or force
          gen = Kin::Sprites::ImageGenerator.new(setinfo.set, @source_dir)
          gen.save(File.join(@sprites_dir, "#{setinfo.name}.png"))
          $stdout.puts("Regenerated #{setinfo.name.inspect} sprite.")
        else
          # Existing sprite file is identical, and the user doesn't want to
          # force re-creating the file.
          setinfo.skipped = true
          $stdout.puts("Ignoring #{setinfo.name.inspect} sprite (unchanged).")
        end
      end

      ##
      # Generates the SASS partial for all sprites.
      #
      # @api private
      #
      def generate_sass!
        sass = @sets.map do |setinfo|
          set_sass = "// #{setinfo.name} sprite "
          set_sass += "=" * (80 - 13 - setinfo.name.length)
          set_sass += Kin::Sprites::SassGenerator.new(
            setinfo.set, setinfo.name).to_sass('/images/sprites')
        end.join("\n")

        FileUtils.mkdir_p(File.dirname(@sass_partial))

        File.open(@sass_partial, 'w') do |f|
          f.puts(TEMPLATE.sub(/^SASS/, sass))
        end

        $stdout.puts('Saved SASS partial.')
      end

      ##
      # Creates a fresh .hashes file containing hashes for the currently
      # loaded sets.
      #
      # @api private
      #
      def dump_hashes!
        hashes = @sets.inject({}) do |hashes, setinfo|
          hashes[setinfo.name] = setinfo.set.hash ; hashes
        end

        File.open(@dot_hashes, 'w') do |f|
          f.puts(YAML.dump(hashes))
        end
      end

      ##
      # Returns if a sprite needs to be regenerated.
      #
      # @api private
      #
      def requires_regenerating?(setinfo)
        hash_for(setinfo.name) != setinfo.set.hash ||
          (! File.exists?(File.join(@sprites_dir, "#{setinfo.name}.png")))
      end

      ##
      # Returns the hash checksum for the current sprite file, if it exists.
      #
      # @param [String] name
      #   The name of the sprite to check.
      #
      # @return [String, nil]
      #   Returns a string if a hash was available, otherwise nil.
      #
      # @api private
      #
      def hash_for(name)
        @_sprite_hashes ||= begin
          File.exists?(@dot_hashes) ? YAML.load(File.read(@dot_hashes)) : {}
        end

        @_sprite_hashes[name]
      end
    end # RakeTaskRunner
  end # Sprites
end # Kin

__END__
// The mixins in this file are automatically generated by the `sprites` rake
// task provided in the Kin gem. Don't edit this file directly; rather you
// should change config/sprites.yaml and then run `rake sprites`.

SASS
