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
