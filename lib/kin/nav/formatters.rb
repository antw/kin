module Kin
  module Nav

    ##
    # Receives a nav instance and transforms it into HTML.
    #
    # @see Kin::Nav::Helper#display_navigation
    #
    # @todo Mix in Merb::Helpers::Tag.
    #
    class BasicFormatter
      ##
      # Creates a new BasicFormatter instance.
      #
      # @param [Kin::Nav::Menu] nav
      #   An instance of a Menu to be rendered as HTML.
      # @param [Symbol] current
      #   The ID of the menu item which is active.
      # @param [Hash] options
      #   A hash of options for customising the menu. See
      #   Kin::Nav::Helper#display_navigation.
      #
      # @api public
      #
      def initialize(nav, current, options)
        @nav = nav
        @current  = current
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
        html_list_item(item, @current == item.id) do
          html_link(item) { item.label(@inject[item.id]) }
        end
      end

      ##
      # Returns a list element, yielding to allow injection of the <a>
      # element.
      #
      # @param [Kin::Nav::Item] item
      #   The item to be transformed to HTML.
      # @param [Boolean] is_active
      #   A flag indicating if this item is the active item.
      #
      # @return [String]
      #
      # @api private
      #
      def html_list_item(item, is_active)
        <<-HTML
          <li id="nav_#{item.id}"#{is_active ? ' class="active"' : ''}>
            #{ yield }
          </li>
        HTML
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
        <<-HTML
          <a href="#{item.url(@resource)}" title="#{item.title(@inject[item.id])}">
            #{ yield }
          </a>
        HTML
      end
    end # Formatter

  end # Nav
end # Kin
