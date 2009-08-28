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
    # @param [Kin::Nav::Formatters::Basic] formatter
    #   A custom formatter to use when rendering the menu as HTML.
    # @param [Block] blk
    #   A block for setting up the menu.
    #
    # @return [Kin::Nav::Menu]
    #   Returns the menu instance which was set up.
    #
    # @api public
    #
    def self.setup(name = :default, formatter = nil, &blk)
      menu = Builder.new(name, formatter).build(&blk)
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
      # @param [Kin::Nav::Formatters::Basic]
      #   A formatter to be used when rendering the menu.
      #
      # @api private
      #
      def initialize(name, formatter = nil)
        @name  = name.to_sym
        @formatter = formatter
        @items = []

        # Used to find the active item on a given page.
        @matchers = Struct.new(:best, :controller, :generic).new([], [], [])
      end

      ##
      # Returns the default formatter to be used when rendering this menu.
      #
      # @return [Kin::Nav::Formatters::Basic]
      #
      # @api public
      #
      def formatter
        @formatter || Merb::Plugins.config[:kin][:nav_formatter]
      end

      ##
      # Adds a controller name / action name pair for matching active items.
      #
      # @param [String] name
      #   The name of an controller and action.
      # @param [Kin::Nav::Item]
      #   A menu item.
      #
      # @return Kin::Nav::ItemMatcher
      #
      # @api semipubic
      #
      def add_active_match(name, item)
        name = name.split('/')
        matcher = ItemMatcher.new(item, name[0..-2].join('/'), name.last)

        if matcher.action?
          @matchers.best << matcher
        elsif matcher.controller?
          @matchers.controller << matcher
        else
          @matchers.generic << matcher
        end

        matcher
      end

      ##
      # Returns the active item based on the given controller.
      #
      # @param [#controller_name, #action_name] controller
      #   An object which behaves like a controller.
      #
      # @return [Symbol]
      #
      # @api semipublic
      #
      def active_item(controller)
        match = lambda { |matcher| matcher.matches?(controller) }

        found =
          @matchers.best.detect(&match)       ||
          @matchers.controller.detect(&match) ||
          @matchers.generic.detect(&match)

        found.item.id if found
      end
    end

    ##
    # Represents a single item/tab in a navigation menu.
    #
    class Item
      attr_reader   :id
      attr_accessor :resource, :guard
      attr_writer   :url, :title

      def inspect
        "#<Kin::Nav::Item #{id}>"
      end

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
      # Returns the item label.
      #
      # @param [Array] inject
      #   An optional array containing (escaped) strings for injection.
      #
      # @return [String]
      #
      # @api public
      #
      def label(inject = nil)
        inject ? @label % inject : @label
      end

      ##
      # Returns the item title (hover tooltip). If no title is set, the label
      # will be used intead.
      #
      # @param [Array] inject
      #   An optional array containing (escaped) strings for injection.
      #
      # @return [String]
      #
      # @api public
      #
      def title(inject = nil)
        @title || label(inject)
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

    ##
    # Used to match a controller name and action name to an item.
    #
    # This is used to find out which item should be considered active for the
    # given controller and action.
    #
    class ItemMatcher
      attr_reader :item

      ##
      # Creates a new ItemMatcher instance.
      #
      # @param [Kin::Nav::Item] item
      #   The item to be considered active for which the given controller and
      #   action pair.
      # @param [String] controller_name
      #   The name of the controller.
      # @param [String] action_name
      #   The name of the action, or '*' if the item is active for all actions
      #   on the controller.
      #
      # @api private
      #
      def initialize(item, controller_name, action_name)
        # Can't use match an action name with a generic controller.
        if controller_name == '*' && action_name != '*'
          # @todo spec
          raise ArgumentError, "Can't match any controller with a specific " \
            "action: #{controller_name}/#{action_name}"
        end

        @item = item
        @controller_name = controller_name

        if match = action_name.match(/^\{(.*)\}$/)
          # The action name is a glob containing multiple actions.
          @action_name = match[1].split(',')
        else
          @action_name = [action_name]
        end
      end

      ##
      # Returns if this matcher has a controller specified.
      #
      # @return [Boolean]
      #
      # @api semipublic
      #
      def controller?
        @controller_name && @controller_name != '*'
      end

      ##
      # Returns if this is matcher has an action specified.
      #
      # @return [Boolean]
      #
      # @api semipublic
      #
      def action?
        @action_name.any? && @action_name.first != '*'
      end

      ##
      # Attempts to match against the given controller.
      #
      # @param [#controller_name, #action_name] controller
      #   An object which behaves like a controller.
      #
      # @return [Boolean]
      #
      # @api semipublic
      #
      def matches?(controller)
        if not controller?
          true
        elsif not action?
          @controller_name == controller.controller_name
        else
          @controller_name == controller.controller_name &&
          @action_name.include?(controller.action_name)
        end
      end
    end # ItemMatcher
  end # Nav
end # Kin
