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
        h = item_hash(item)

        html_list_item(h) do
          html_link(h) { h[:label] }
        end
      end

      ##
      # Creates a hash representing the item's contents. Escapes any injected
      # content.
      #
      # @param [Kin::Nav::Item] item
      #   The nav item for which you want a hash.
      #
      # @todo Deprecate?
      #
      # @api private
      #
      def item_hash(item)
        parsed_label = unless @inject.blank?
          item.label % [@inject[item.id]].flatten.map do |v|
            Merb::Parse.escape_xml(v)
          end
        end

        {
          :id     => item.id,
          :active => (@current == item.id),
          :title  => (item.title || parsed_label || item.label),
          :label  => (parsed_label || item.label),
          :url    => item.url(@resource)
        }
      end

      ##
      # Returns a list element, yielding to allow injection of the <a>
      # element.
      #
      # @param [Hash] h
      #   A hash representing the item.
      #
      # @return [String]
      #
      # @api private
      #
      def html_list_item(h)
        <<-HTML
          <li id="nav_#{h[:id]}"#{h[:active] ? ' class="active"' : ''}>
            #{ yield }
          </li>
        HTML
      end

      ##
      # Returns an anchor element containing a link for the menu item.
      #
      # @param [Hash] h
      #   A hash representing the item.
      #
      # @return [String]
      #
      # @api private
      #
      def html_link(h)
        <<-HTML
          <a href="#{h[:url]}" title="#{h[:title]}">
            #{ yield }
          </a>
        HTML
      end
    end # Formatter

  end # Nav
end # Kin
