require 'showcase-common/masthead'
require 'showcase-common/nav'

# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash... feel free to put your stuff
  # in your piece of it
  Merb::Plugins.config[:showcase_common] = {
    :nav_formatter => Showcase::Common::Nav::BasicFormatter
  }

  # Merb::Plugins.add_rakefiles "showcase-common/merbtasks"
end
