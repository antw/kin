module Kin
  module Nav
    module Formatters
      ##
      # Receives a nav instance and transforms it into HTML.
      #
      # @see Kin::Nav::Helper#display_navigation
      #
      class Basic
        include Merb::Helpers::Tag

        ##
        # Creates a new BasicFormatter instance.
        #
        # @param [Kin::Nav::Menu] nav
        #   An instance of a Menu to be rendered as HTML.
        # @param [#controller_name, #action_name] controller
        #   An object which behaves like a controller.
        # @param [Hash] options
        #   A hash of options for customising the menu. See
        #   Kin::Nav::Helper#display_navigation.
        #
        # @api public
        #
        def initialize(nav, controller, options)
          @nav = nav
          @current  = nav.active_item(controller)

          @resource = options[:resource]
          @inject   = options.fetch(:inject, {})
          @guards   = options.fetch(:guard, {})

          # Escape injected content.
          @inject.each do |item_id, contents|
            contents = Array(contents)
            contents.map! { |v| Merb::Parse.escape_xml(v) }
            @inject[item_id] = contents
          end
        end

        ##
        # Transforms the menu given to +initialize+ into a string containing
        # HTML.
        #
        # @return [String]
        #   HTML containing the rendered menu. A collection of <li> elements
        #   contained in a <ul>.
        #
        # @api public
        #
        def to_html
          '<ul>%s</ul>' % @nav.items.map do |item|
            trasform_item_to_html(item) if item.display?(@guards)
          end.join("\n")
        end

        private # ==============================================================

        ##
        # Receives an individual nav item and transforms it into HTML.
        #
        # @param [Kin::Nav::Item] item
        #   The nav item to be transformed.
        #
        # @return [String]
        #   A string containing an HTML <li> element.
        #
        # @api private
        #
        def trasform_item_to_html(item)
          html_list_item(item) do
            html_link(item) { item.label(@inject[item.id]) }
          end
        end

        ##
        # Returns a list element, yielding to allow injection of the <a>
        # element.
        #
        # @param [Kin::Nav::Item] item
        #   The item to be transformed to HTML.
        #
        # @return [String]
        #
        # @api private
        #
        def html_list_item(item)
          opts =
            case item.id == @current
              when true  then { :id => "nav_#{item.id}", :class => 'active' }
              when false then { :id => "nav_#{item.id}" }
            end

          tag(:li, yield, opts)
        end

        ##
        # Returns an anchor element containing a link for the menu item.
        #
        # @param [Kin::Nav::Item] item
        #   The item to be transformed to HTML.
        #
        # @return [String]
        #
        # @api private
        #
        def html_link(item)
          tag(:a, yield,
            :href  => item.url(@resource),
            :title => item.title(@inject[item.id])
          )
        end
      end # Basic

      ##
      # A formatter used when a navigation menu has items which should appear
      # on the right of the UI. Right-floated items are styled slightly
      # differently.
      #
      class HasRight < Basic
        class_inheritable_accessor :right_items

        private

        ##
        # Receives an individual nav item and transforms it into HTML.
        #
        # Items specified as being a right_item will be styled differently
        # to the others.
        #
        # @param [Kin::Nav::Item] item
        #   The nav item to be transformed.
        #
        # @return [String]
        #   A string containing an HTML <li> element.
        #
        # @api private
        #
        def trasform_item_to_html(item)
          return super unless self.class.right_items.include?(item.id)

          html_list_item(item) do
            link = html_link(item) { item.label(@inject[item.id]) }

            <<-HTML
              <span class="right_border">&nbsp;</span>
              <span class="bg">#{ link }</span>
            HTML
          end
        end # transform_item_to_html
      end # HasRight

      ##
      # Creates a HasRight subclass.
      #
      # @param [Symbol] *items
      #   Symbols matching the given items which should have the custom style
      #   applied.
      #
      # @return [Class]
      #   A subclass of the HasRight formatter.
      #
      # @example
      #   :formatter => Kin::Nav::Formatters::HasRight(:user, :guest)
      #
      # @api public
      #
      def self.HasRight(*items)
        klass = Class.new(Kin::Nav::Formatters::HasRight)
        klass.right_items = Set.new(items)
        klass
      end

      ##
      # A formatter used for creating subnavs.
      #
      class Subnav < Basic
        private

        ##
        # Receives an individual nav item and transforms it into HTML.
        #
        # Wraps the contents of the link in a span.pill and span.icon to
        # enable futher styling.
        #
        # @param [Kin::Nav::Item] item
        #   The nav item to be transformed.
        #
        # @return [String]
        #   A string containing an HTML <li> element.
        #
        # @api private
        #
        def trasform_item_to_html(item)
          html_list_item(item) do
            html_link(item) do
              <<-HTML
                <span class="pill">
                  <span class="icon">
                    #{item.label(@inject[item.id])}
                  </span>
                </span>
              HTML
            end
          end
        end # transform_item_to_html
      end # Subnav

    end # Formatters
  end # Nav
end # Kin
