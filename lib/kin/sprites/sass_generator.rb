module Kin
  module Sprites
    ##
    # Converts an IconSet to a SASS partial.
    #
    class SassGenerator
      TEMPLATE = File.read(__FILE__).split(/^__END__/)[1]

      ##
      # Creates a new Generator instance.
      #
      # @param [IconSet] set
      #   An IconSet instance.
      # @param [String] name
      #   The name of this sprite.
      #
      # @api public
      #
      def initialize(set, name)
        @set, @name = set, name
      end

      ##
      # Converts the icon set to a SASS partial.
      #
      # @param [String] dir
      #   The web directory in which the sprite files are located (no trailing
      #   space please).
      #
      # @api public
      #
      def to_sass(dir)
        # Holds all the if/else statements.
        conditions = []
        conditions << if_statement(@set[0], true)
        @set[1..-1].each { |icon| conditions << if_statement(icon) }

        # Permits supplying an offset, rather than an icon name.
        conditions << '  @else'
        conditions << '    !pos = !icon'
        conditions << ''

        # Put the data into the template.
        template = TEMPLATE.dup
        template.gsub!(/NAME/, @name)
        template.gsub!(/DIR/, dir)
        template.gsub!(/CONDITIONS/, conditions.join("\n"))
        template
      end

      private

      ##
      # Creates an if statement for the given icon.
      #
      # @param [String] icon
      #   The name of an icons
      # @param [Boolean] is_first
      #   Is this the first icon to appear in the if statement?
      #
      def if_statement(icon, is_first = false)
        else_modifier = is_first ? '' : 'else '

        %[  @#{else_modifier}if !icon == "#{icon}"\n] +
        %[    !pos = -#{@set.location_of(icon)}px]
      end
    end # SassGenerator
  end # Sprites
end # Kin

__END__

=NAME-icon(!icon, !hpos = 0px, !voff = 0px)
  !pos = !voff
CONDITIONS
  :background = "url(DIR/NAME.png)" !hpos !pos "no-repeat"

=NAME-icon-pos(!icon, !hpos = 0px, !voff = 0px)
  !pos = !voff
CONDITIONS
  :background-position = !hpos !pos
