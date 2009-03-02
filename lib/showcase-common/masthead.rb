module Showcase
  module Common
    module Masthead
      ##
      # Most pages on Showcase have a masthead of some sort. The masthead fits
      # beneath the main navigation and the page content. Typically it
      # contains the page title and some other interesting information.
      #
      #   +--------+----------+--------------+          +--------------------+
      #   |  Sets  |  Search  |  My account  |          |  Upload a new set  |
      #   +--------+----------+--------------+----------+--------------------+
      #   |  [Title]                                          [Right title]  |
      #   |  [Subtitle]                                    [Right subtitle]  |
      #   +  --------------------------------------------------------------  +
      #   |                                                                  |
      #   |  Page contents                                                   |
      #   |                                                                  |
      #   +------------------------------------------------------------------+
      #
      # See the #masthead helper for more information on how to build a
      # masthead.
      #
      class Builder
        attr_accessor :no_border

        def initialize
          @title, @right_title = nil, nil
          @subtitle, @right_subtitle = nil, nil
        end

        ##
        # Returns the current title. If you supply a non-nil argument, the
        # title will be set to whatever is provided.
        #
        # @param  [String] _title The new title.
        # @return [String]        The masthead title.
        #
        def title(value = nil)
        end

        ##
        # Returns the current right title. If you supply a non-nil argument,
        # the right title will be set to whatever is provided.
        #
        # @param  [String] value The new right title.
        # @return [String]       The masthead right title.
        #
        def right_title(value = nil)
        end

        ##
        # Returns the current subtitle. If you supply a non-nil argument, the
        # subtitle will be set to whatever is provided.
        #
        # @param  [String] value The new subtitle.
        # @return [String]       The masthead subtitle.
        #
        def subtitle(value = nil)
        end

        ##
        # Returns the current right subtitle title. If you supply a non-nil
        # argument, the subtitle will be set to whatever is provided.
        #
        # @param  [String] value The new right subtitle.
        # @return [String]       The masthead right subtitle.
        #
        def right_subtitle(value = nil)
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
            def #{meth}(value = nil)
              @#{meth} = Merb::Parse.escape_xml(value.to_s) if value
              @#{meth}
            end
          RUBY
        end

        ##
        # Returns whether this masthead builder has an "extras".
        #
        # Extras are defined as being a right-hand title or right-hand
        # subtitle. Generally, if the builder has no extras, the .extras div
        # will not be rendered by #to_html
        #
        # @return [TrueClass|FalseClass]
        #
        def has_extras?
          not @right_title.nil? or not @right_subtitle.nil?
        end

        ##
        # Returns the masthead as HTML.
        # @return [String] The masthead with all the various titles.
        #
        def to_html
          formatted_title = '<h1>%s</h1>' % title
          formatted_subtitle = '<span class="subtitle">%s</span>' % subtitle

          extras = if has_extras?
            '<div class="extra">%s %s</div>' % [
              '<span class="main">%s</span>' % (right_title || '&nbsp;'),
              '<span class="subtitle">%s</span>' % right_subtitle
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
        # @return [Showcase::MastheadBuilder]
        #
        def masthead_builder
          @_masthead_builder ||= Showcase::Common::Masthead::Builder.new
        end
      end # Helper
    end # Masthead
  end # Common
end # Showcase