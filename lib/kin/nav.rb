nav = File.expand_path(File.join(File.dirname(__FILE__), 'nav'))

require File.join(nav, 'builder')
require File.join(nav, 'formatters')
require File.join(nav, 'helper_mixin')

module Kin
  ##
  # The Nav class is used when creating main navigation navs. Typically this
  # is the "Sets", "Search", "Your Account", etc nav, but is also used for the
  # sets subnav.
  #
  module Nav
    # Raised when an Item requires a resource, and one isn't provided.
    class MissingResource < StandardError; end

    ##
    # Sets up a new menu instance. See Showcase#setup_navs! for examples.
    #
    # @param [Symbol] name
    #   A name for this menu.
    # @param [Block] blk
    #   A block for setting up the menu.
    #
    # @return [Kin::Nav::Menu]
    #   Returns the menu instance which was set up.
    #
    # @api public
    #
    def self.setup(name = :default, &blk)
      menu = Builder.new(name).build(&blk)
      menu.freeze
      menu.items.freeze
      menu.items.each { |i| i.freeze }
      register(menu)
      menu
    end

    ##
    # Returns menu instance identified by +name+.
    #
    # @param [Symbol] name
    #   The name of the menu to return. If no name is given, the default menu
    #   will be returned.
    #
    # @return [Kin::Nav::Menu]
    #   Returns the Menu instance identified by +name+.
    #
    # @api public
    #
    def self.get(name = :default)
      @registry ||= {}
      @registry[name]
    end

    ##
    # Puts a menu instance into the registry.
    #
    # @param [Kin::Nav::Menu] menu
    #   Registers a menu.
    #
    # @api private
    #
    def self.register(menu)
      @registry ||= {}
      @registry[menu.name] = menu
    end

    ##
    # Resets the registry.
    #
    # @api public
    #
    def self.reset!
      @registry = {}
      nil
    end

    ##
    # Represents a navigation menu - contains one or more items which are
    # links to other parts of the application.
    #
    class Menu
      attr_reader :name, :items

      ##
      # Creates a new menu. Don't use Menu.new, use Nav.setup.
      #
      # @param [Symbol] name
      #   A name for this nav.
      #
      # @api private
      #
      def initialize(name)
        @name  = name.to_sym
        @items = []
      end
    end

    ##
    # Represents a single item/tab in a navigation menu.
    #
    class Item
      attr_reader   :id, :label
      attr_accessor :resource, :title, :guard
      attr_writer   :url

      ##
      # @param [Symbol] id
      #   A unique identifier for this item.
      # @param [String] label
      #   The text label for this item.
      #
      # @api private
      #
      def initialize(id, label)
        @id, @label = id, label
        @resource, @url, @title, @guard = nil, nil, nil, nil
      end

      ##
      # Returns if this item can be displayed.
      # @param [Array] Permitted guard conditions.
      #
      # @api semipublic
      #
      def display?(guards = {})
        @guard.nil? || guards[@guard]
      end

      ##
      # Returns the URL for this Item. If the item expects a resource, it
      # should be provided as the sole parameter to this method.
      #
      # @api semipublic
      #
      def url(given_resource = nil)
        expects_resource? ? resource_url(given_resource) : @url
      end

      private

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
        raise MissingResource, "Nav item #{id.inspect} expected a " \
          "resource to generate a URL, and none was given" unless given

        # Merb doesn't expect a verb when generating a URL for resource/show.
        case @resource
          when :show then Merb::Router.resource(given, {})
          else            Merb::Router.resource(given, @resource, {})
        end
      end

    end # Item
  end # Nav
end # Kin
