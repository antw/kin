module Potion
  ##
  # The Nav class is used when creating main navigation navs. Typically this
  # is the "Sets", "Search", "Your Account", etc nav, but is also used for the
  # sets subnav.
  #
  module Nav
    # Raised when an Item requires a resource, and one isn't provided.
    class MissingResource < StandardError; end

    ##
    # Sets up a new nav instance. See Showcase#setup_navs! for examples.
    #
    # @param [Symbol] name A name for this nav.
    # @param [Block]  blk  A block for setting up the menu.
    #
    #
    def self.setup(name = :default, &blk)
      nav = Builder.new(name).build(&blk)
      nav.freeze
      nav.items.freeze
      nav.items.each { |i| i.freeze }
      register(nav)
      nav
    end

    ##
    # Returns an instance of Nav which has already been configured, identified
    # by the given name.
    #
    # @param [Symbol] name
    #   The name of the nav to return. If no name is given, the default nav
    #   will be returned.
    # @return [Potion::Nav]
    #
    def self.get(name = :default)
      @registry ||= {}
      @registry[name]
    end

    ##
    # Puts a nav instance into the registry.
    #
    def self.register(nav)
      @registry ||= {}
      @registry[nav.name] = nav
    end

    ##
    # Resets the registry.
    #
    def self.reset!
      @registry = {}
    end

    # Menu ===================================================================

    class Menu
      attr_reader :name, :items

      ##
      # Creates a new nav. Expects a name to be given; if none is supplied, it
      # will be assumed you are setting up the default.
      #
      # Don't use Nav.new, use Nav.setup.
      #
      # @param [Symbol] name
      #   A name for this nav.
      #
      def initialize(name)
        @name  = name.to_sym
        @items = []
      end
    end

    # Item ===================================================================

    ##
    # Represents a single item/tab in a navigation menu.
    #
    class Item
      attr_reader   :id, :label
      attr_accessor :resource, :title, :guard
      attr_writer   :url

      ##
      # @param [Symbol] id    A unique identifier for this item.
      # @param [String] label The text label for this item.
      #
      def initialize(id, label)
        @id, @label = id, label
        @resource, @url, @title, @guard = nil, nil, nil, nil
      end

      ##
      # Returns if this item can be displayed.
      # @param [Array] Permitted guard conditions.
      #
      def display?(guards = {})
        @guard.nil? || guards[@guard]
      end

      ##
      # Returns the URL for this Item. If the item expects a resource, it
      # should be provided as the sole parameter to this method.
      #
      def url(given_resource = nil)
        expects_resource? ? resource_url(given_resource) : @url
      end

      #######
      private
      #######

      ##
      # Returns true if this item expects a resource in order to generate a
      # URL.
      #
      def expects_resource?
        not @resource.nil?
      end

      ##
      # Takes a resource and generates a URL.
      #
      def resource_url(given)
        if given
          if @resource == :show
            Merb::Router.resource(given, {})
          else
            Merb::Router.resource(given, @resource, {})
          end
        else
          raise MissingResource, "No resource was given to nav item :#{id}"
        end
      end # resource_url
    end # Item

    # Builder ================================================================

    class Builder
      def initialize(name)
        @nav = Menu.new(name)
        @item_builders = []
      end

      def build
        yield self if block_given?
        @item_builders.each { |b| @nav.items << b.item }
        @nav
      end

      def add(name, label)
        ibuilder = ItemBuilder.new(name.to_sym, label)
        @item_builders << ibuilder
        ibuilder
      end
    end

    class ItemBuilder
      attr_reader :item

      def initialize(name, label)
        @item = Item.new(name, label)
      end

      [:title, :resource, :url, :guard].each do |meth|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{meth}(value)
            @item.#{meth} = value
            self
          end
        RUBY
      end
    end

    # Formatter ==============================================================

    class BasicFormatter
      def initialize(nav, current, options)
        @nav = nav
        @current  = current
        @resource = options[:resource]
        @inject   = options.fetch(:inject, {})
        @guards   = options.fetch(:guard, {})
      end

      def to_html
        '<ul>%s</ul>' % @nav.items.map do |item|
          trasform_item_to_html(item) if item.display?(@guards)
        end.join("\n")
      end

      private

      def trasform_item_to_html(item)
        h = item_hash(item)

        <<-HTML
          <li id="nav_#{h[:id]}"#{h[:active] ? ' class="active"' : ''}>
            <a href="#{h[:url]}" title="#{h[:title]}">
              #{h[:label]}
            </a>
          </li>
        HTML
      end

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
    end

    # Helper ===============================================================

    module Helper
      ##
      # Displays the navigation identified by name.
      #
      # You can change the formatter used to generate HTML for the menu by
      # altering Merb::Plugins.config[:potion][:nav_formatter].
      #
      # @param [Symbol] name    The name of the menu to be displayed.
      # @param [Symbol] current The ID of the active nav item
      # @param [Hash]   options Options to be supplied to the formatter.
      #
      def display_navigation(name, current, options = {})
        (options[:formatter] || Merb::Plugins.config[:potion][:nav_formatter]).new(
          Potion::Nav.get(name), current, options
        ).to_html
      end
    end # Helper

  end # Nav
end # Potion
