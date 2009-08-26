module Kin
  module Nav

    ##
    # Mix into your Merb::GlobalHelpers module (not done automatically).
    #
    module Helper
      ##
      # Displays the navigation identified by +name+.
      #
      # You can change the formatter used to generate HTML for all menus by
      # altering Merb::Plugins.config[:kin][:nav_formatter].
      #
      # @param [Symbol] name
      #   The name of the menu to be displayed.
      # @param [Hash] options
      #   Options to be supplied to the formatter.
      #
      # @option options [Kin::Nav::Formatter] :formatter
      #   Overrides the default formatter.
      # @option options [Hash] :inject
      #   Injects content into a nav item.
      # @option option [Hash] :guard
      #   A hash of guard conditions.
      #
      # @return [String]
      #   A string containing HTML for the navigation.
      #
      # @example Injecting content
      #   # Injects '5' into the :comments nav item. See
      #   # specs/fixture/app/views/nav_specs/content_injection.html.haml
      #   display_navigation :default, :home, :inject => { :comments => '5' }
      #
      # @example Guard conditions
      #   # Displays any nav items which have the :admin guard condition set.
      #   # See specs/fixture/app/views/nav_specs/guard_*.html.haml
      #   display_navigation :default, :home, :guard => { :admin => true }
      #
      # @example Using a resource to generate a URL
      #   # A resource to be passed to nav items which use a resource URL.
      #   # See specs/fixture/app/views/nav_specs/resource_url.html.haml
      #   display_navigation :default, :home, :resource => #<User>
      #
      # @api public
      #
      def display_navigation(name, options = {})
        (options[:formatter] || Merb::Plugins.config[:kin][:nav_formatter]).new(
          Kin::Nav.get(name), self, options
        ).to_html
      end
    end

  end # Nav
end # Kin
