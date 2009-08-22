module Kin
  module Masthead
    ##
    # Most pages on Showcase have a masthead of some sort. The masthead fits
    # beneath the main navigation and the page content. Typically it contains
    # the page title and some other interesting information.
    #
    #   +--------+----------+---------+              +--------------------+
    #   |  Sets  |  Search  |  Admin  |              |  Upload a new set  |
    #   +--------+----------+---------+--------------+--------------------+
    #   |  [Title]                                         [Right title]  |
    #   |  [Subtitle]                                   [Right subtitle]  |
    #   +-----------------------------------------------------------------+
    #   |                                                                 |
    #   |  Page contents                                                  |
    #   |                                                                 |
    #   +-----------------------------------------------------------------+
    #
    # See the #masthead helper for more information on how to build a
    # masthead.
    #
    class Builder
      include Merb::Helpers::Tag

      DEFAULT_CLASSES = {
        :title          => ''.freeze,
        :subtitle       => 'subtitle'.freeze,
        :right_title    => 'main'.freeze,
        :right_subtitle => 'subtitle'.freeze
      }.freeze

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
        # def title(value = nil, options = nil)
        #   @title = value if value
        #   @options[:title] = options if options
        #   @title
        # end
        #
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{meth}(value = nil, options = nil)
            @#{meth} = value if value
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
        formatted_title = formatted(:title, :h1)
        formatted_subtitle = formatted(:subtitle) if @subtitle

        extras = if has_extras?
          '<div class="extra">%s %s</div>' % [
            formatted(:right_title) || '<span class="main">&nbsp;</span>',
            @right_subtitle ? formatted(:right_subtitle) : ''
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
      def formatted(field, wrap_in = :span)
        if instance_variable_get(:"@#{field}").blank?
          return nil
        else
          value = instance_variable_get(:"@#{field}").to_s
        end

        options = @options[field] || {}
        link    = options.delete(:link)

        # Escape required?
        unless options.delete(:no_escape)
          value = Merb::Parse.escape_xml(value.to_s)
        end

        # Link required?
        if link
          value = '<a href="%s" title="%s">%s</a>' % [link, value, value]
        end

        if options[:class]
          options[:class] += ' %s' % DEFAULT_CLASSES[field]
        elsif field != :title
          options[:class] = DEFAULT_CLASSES[field]
        end

        tag(wrap_in, value, options)
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
      # @return [Kin::MastheadBuilder]
      #
      def masthead_builder
        @_masthead_builder ||= Kin::Masthead::Builder.new
      end
    end # Helper
  end # Masthead
end # Kin
