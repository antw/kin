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

      CSS_CLASSES = {
        :title          => ''.freeze,
        :subtitle       => 'subtitle'.freeze,
        :right_title    => 'main'.freeze,
        :right_subtitle => 'subtitle'.freeze
      }.freeze

      ##
      # Creates a new masthead builder.
      #
      # @api semipublic
      #
      def initialize
        @title = @right_title = @subtitle = @right_subtitle = nil
        @options = Hash.new { |hash, key| hash[key] = {} }
      end

      ##
      # Builds a masthead.
      #
      # Yields the builder instance providing a DSL for setting up the
      # masthead as desired.
      #
      # @return [Kin::Nav::Builder]
      #
      # @yield [Kin::Nav::Builder]
      #
      # @api semipublic
      #
      def build
        yield self
        self
      end

      ##
      # Returns the current title. If you supply a non-nil argument, the title
      # will be set to whatever is provided.
      #
      # @param  [String] value   The new title.
      # @param  [Hash]   options A hash containing extraoptions.
      # @return [String]         The masthead title.
      #
      # @api public
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
      # @api public
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
      # @api public
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
      # @api public
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
      # Returns the HTML representation of the masthead.
      #
      # @return [String]
      #   The masthead with all the various titles.
      #
      # @api public
      #
      def to_html
        <<-HTML
          <div id="masthead">
            <div class="details">
              #{ formatted(:title, :h1) }
              #{ formatted(:subtitle) }
            </div>

            #{ extras_as_html }
          </div>
        HTML
      end

      private # ==============================================================

      ##
      # Returns <div.extra> containing the right-hand stuff.
      #
      # @return [String, nil]
      #   Returns nil if no <div.extra> is needed.
      #
      # @api private
      #
      def extras_as_html
        unless @right_title.nil? && @right_subtitle.nil?
          <<-HTML
            <div class="extra">
              #{ formatted(:right_title) }
              #{ formatted(:right_subtitle) }
            </div>
          HTML
        end
      end

      ##
      # Returns the HTML element containing the value for the field specified
      # by +field+.
      #
      # @param [Symbol] field
      #   The name of the field whose value you wish to retrieve.
      # @param [Symbol] wrap_in
      #   The HTML element which should wrap the field value.
      #
      # @return [String, nil]
      #   nil will be returned if no the field should not be displayed.
      #
      # @api semipublic
      #
      def formatted(field, wrap_in = :span)
        value = value_for(field)
        options = @options[field]

        if value.blank?
          # If the field is blank, we want to return _unless_ the field is the
          # right subtitle, and a right title is set (in which case a title
          # element is needed to push the subtitle down).
          if field != :right_title || value_for(:right_subtitle).blank?
            return nil
          else
            value = '&nbsp;'
            options[:no_escape] = true
          end
        end

        # Escape required?
        unless options.delete(:no_escape)
          value = Merb::Parse.escape_xml(value)
        end

        # Link required?
        if options.has_key?(:link)
          value = %[<a href="#{options.delete(:link)}"] +
                    %[ title="#{value}">#{value}</a>]
        end

        # Set the CSS class.
        if options[:class]
          options[:class] = [options[:class], CSS_CLASSES[field]].join(' ')
        elsif CSS_CLASSES[field] != ''
          options[:class] = CSS_CLASSES[field]
        end

        tag(wrap_in, value, options)
      end

      ##
      # Retrieves a value for the specified +field+.
      #
      # @param [Symbol] field
      #   The name of the field whose value you wish to retrieve.
      #
      # @return [String, nil]
      #   Returns nil if nothing is set, or a string version of whatever the
      #   field is set to.
      #
      # @api private
      #
      def value_for(field)
        value = instance_variable_get(:"@#{field}")
        value.nil? ? nil : value.to_s
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
      # @example In a template
      #   - masthead do
      #     - title @set
      #     - subtitle "This set contains #{@set.contents}"
      #
      # @api public
      #
      def masthead(options = {}, &blk)
        masthead_builder.build(&blk)
      end

      ##
      # Returns the MastheadBuilder instance for the current request.
      #
      # @return [Kin::MastheadBuilder]
      #
      # @api public
      #
      def masthead_builder
        @_masthead_builder ||= Kin::Masthead::Builder.new
      end
    end # Helper
  end # Masthead
end # Kin
