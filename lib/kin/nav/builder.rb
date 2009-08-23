module Kin
  module Nav

    ##
    # Provides the DSL used to create navigation menus.
    #
    class Builder
      ##
      # Returns a new Builder instance.
      #
      # @param [Symbol] name
      #   A unique name for the Menu instance.
      #
      # @api private
      #
      def initialize(name)
        @nav = Menu.new(name)
        @item_builders = []
      end

      ##
      # Builds the nav menu. Yields the builder to provide a nicer DSL.
      #
      # @return [Kin::Nav::Menu]
      # @yield  [Kin::Nav::Builder] The builder instance.
      #
      # @api private
      #
      def build
        yield self if block_given?
        @item_builders.each { |b| @nav.items << b.item }
        @nav
      end

      ##
      # Adds an item to the menu, returning an item builder which provides a
      # DSL for customising the item.
      #
      # @param [Symbol] name
      #   A unique name for the Item instance.
      # @param [String] label
      #   Text which will be used on the item when rendered as HTML.
      #
      # @return [Kin::Nav::ItemBuilder]
      #
      # @see Kin::Nav.build
      #
      # @api public
      #
      def add(name, label)
        ibuilder = ItemBuilder.new(name.to_sym, label)
        @item_builders << ibuilder
        ibuilder
      end
    end

    ##
    # Provides the DSL used to create navigation items.
    #
    class ItemBuilder
      attr_reader :item

      ##
      # Returns a new Builder instance.
      #
      # @param [Symbol] name
      #   A unique name for the Item instance.
      # @param [String] label
      #   Text which will be used on the item when rendered as HTML.
      #
      # @api private
      #
      def initialize(name, label)
        @item = Item.new(name, label)
      end

      ##
      # Sets the (rollover) title applied to the anchor element.
      #
      # @param [String] Text to be used as the title.
      #
      # @return [Kin::Nav::ItemBuilder]
      #   Returns self.
      #
      # @api public
      #
      def title(title)
        @item.title = title
        self
      end

      ##
      # Sets a resource verb to be used to create a URL.
      #
      # @param [Symbol] The resource verb.
      #
      # @return [Kin::Nav::ItemBuilder]
      #   Returns self.
      #
      # @api public
      #
      def resource(verb)
        @item.resource = verb
        self
      end

      ##
      # Sets a URL to be used for the item.
      #
      # @param [#to_s] A URL.
      #
      # @return [Kin::Nav::ItemBuilder]
      #   Returns self.
      #
      # @api public
      #
      def url(url)
        @item.url = url.to_s
        self
      end

      ##
      # Sets a guard condition so that the item is only displayed if the
      # guard is +true+ when the item is rendered.
      #
      # @param [Symbol] The guard condition.
      #
      # @return [Kin::Nav::ItemBuilder]
      #   Returns self.
      #
      # @see Kin::Nav::Helper#display_navigation
      #
      # @api public
      #
      def guard(guard)
        @item.guard = guard
        self
      end
    end

  end # Nav
end # Kin
