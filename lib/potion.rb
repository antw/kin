require 'merb-helpers'

require 'potion/form_builder'
require 'potion/masthead'
require 'potion/nav'

# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash... feel free to put your stuff
  # in your piece of it
  Merb::Plugins.config[:potion] = {
    :nav_formatter => Potion::Nav::BasicFormatter
  }

  # Merb::Plugins.add_rakefiles "potion/merbtasks"
end

##
# Alias Enumerable#inject as Enumerable#reduce on Ruby 1.8.6.
#
if RUBY_VERSION <= '1.8.6' && (! Enumerable.method_defined?(:reduce))
  module Enumerable
    alias_method :reduce, :inject
  end
end
