module Potion
  module Masthead
    ##
    # Most pages on Showcase have a masthead of some sort. The masthead fits
    # beneath the main navigation and the page content. Typically it contains
    # the page title and some other interesting information.
    #
    #   +--------+----------+--------------+            +--------------------+
    #   |  Sets  |  Search  |  My account  |            |  Upload a new set  |
    #   +--------+----------+--------------+------------+--------------------+
    #   |  [Title]                                            [Right title]  |
    #   |  [Subtitle]                                      [Right subtitle]  |
    #   +  ----------------------------------------------------------------  +
    #   |                                                                    |
    #   |  Page contents                                                     |
    #   |                                                                    |
    #   +--------------------------------------------------------------------+
    #
    # See the #masthead helper for more information on how to build a
    # masthead.
    #
    class Builder
      attr_accessor :no_border
      attr_reader   :options

      def initialize
        @title, @right_title = nil, nil
        @subtitle, @right_subtitle = nil, nil
        @options = {}
      end

      ##
      # Returns the current title. If you supply a non-nil argument, the title
      # will be set to whatever is provided.
      #
      # @param  [String] value   The new title.
      # @param  [Hash]   options A hash containing extraoptions.
      # @return [String]         The masthead title.
      #
      def title(value = nil, options = nil)
      end

      ##
      # Returns the current right title. If you supply a non-nil argument, the
      # right title will be set to whatever is provided.
      #
      # @param  [String] value   The new right title.
      # @param  [Hash]   options A hash containing extraoptions.
      # @return [String]         The masthead right title.
      #
      def right_title(value = nil, options = nil)
      end

      ##
      # Returns the current subtitle. If you supply a non-nil argument, the
      # subtitle will be set to whatever is provided.
      #
      # @param  [String] value   The new subtitle.
      # @param  [Hash]   options A hash containing extraoptions.
      # @return [String]         The masthead subtitle.
      #
      def subtitle(value = nil, options = nil)
      end

      ##
      # Returns the current right subtitle title. If you supply a non-nil
      # argument, the subtitle will be set to whatever is provided.
      #
      # @param  [String] value   The new right subtitle.
      # @param  [Hash]   options A hash containing extraoptions.
      # @return [String]         The masthead right subtitle.
      #
      def right_subtitle(value = nil, options = nil)
      end

      %w( title right_title subtitle right_subtitle ).each do |meth|
        # Example:
        #
        # def title(value = nil)
        #   @title = Merb::Parse.escape_xml(value.to_s) if value
        #   @title
        # end
        #
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{meth}(value = nil, options = nil)
            @#{meth} = Merb::Parse.escape_xml(value.to_s) if value
            @options[:#{meth}] = options if options
            @#{meth}
          end
        RUBY
      end

      ##
      # Returns the masthead as HTML.
      # @return [String] The masthead with all the various titles.
      #
      def to_html
        formatted_title = '<h1>%s</h1>' % formatted(:title)

        formatted_subtitle = if @subtitle
          '<span class="subtitle">%s</span>' % formatted(:subtitle)
        end

        extras = if has_extras?
          formatted_rsubtitle = if @right_subtitle
            '<span class="subtitle">%s</span>' % formatted(:right_subtitle)
          end

          '<div class="extra">%s %s</div>' % [
            '<span class="main">%s</span>' % (formatted(:right_title) || '&nbsp;'),
            formatted_rsubtitle
          ]
        end

        <<-HTML
          <div id="masthead"#{no_border ? ' class="no_border"' : ''}>
            <div class="details">
              #{formatted_title}
              #{formatted_subtitle}
            </div>

            #{extras}
          </div>
        HTML
      end

      ##
      # Builds a masthead.
      #
      def build
        yield self
        self
      end

      #######
      private
      #######

      ##
      # Returns whether this masthead builder has an "extras".
      #
      # Extras are defined as being a right-hand title or right-hand subtitle.
      # Generally, if the builder has no extras, the .extras div will not be
      # rendered by #to_html
      #
      # @return [TrueClass|FalseClass]
      #
      def has_extras?
        not @right_title.nil? or not @right_subtitle.nil?
      end

      ##
      # Returns formatted text for a given field. Wraps the text in a link if
      # one is required, otherwise the text is returned on it's own.
      #
      def formatted(field)
        value = instance_variable_get(:"@#{field}")
        url   = @options[field] && options[field][:link]

        if value && url
          '<a href="%s" title="%s">%s</a>' % [url, value, value]
        else
          value
        end
      end
    end

    ##
    # Controller mixin for making mastheads.
    #
    module Helper
      protected

      ##
      # Builds a masthead.
      #
      # Takes a block allowing you to easily set the masthead's attributes.
      # Note that the block is evaluated within the MastheadBuilder instance
      # itself.
      #
      # @example [In a template]
      #   - masthead(:no_border => true) do
      #     - title @set
      #     - subtitle "This set contains #{@set.contents}"
      #
      def masthead(options = {}, &blk)
        masthead_builder.no_border = options.fetch(:no_border, false)
        masthead_builder.build(&blk)
      end

      ##
      # Returns the MastheadBuilder instance for the current request.
      #
      # @api private
      # @return [Potion::MastheadBuilder]
      #
      def masthead_builder
        @_masthead_builder ||= Potion::Masthead::Builder.new
      end
    end # Helper
  end # Masthead
end # Potion