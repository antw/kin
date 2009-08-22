require 'merb-helpers'

kin = File.expand_path(File.join(File.dirname(__FILE__), 'kin'))

require File.join(kin, 'form_builder')
require File.join(kin, 'masthead')
require File.join(kin, 'nav')

# Make sure we're running inside Merb.
if defined?(Merb::Plugins)
  # Default nav formatter. Can be overridden in an after_app_loads block, or
  # on a case-by-case basis in +display_navigation+.
  Merb::Plugins.config[:kin] = { :nav_formatter => Kin::Nav::BasicFormatter }

  Merb::BootLoader.after_app_loads do
    if defined?(Sass)
      template_location =
        Merb::Plugins.config[:sass][:template_location] ||
        Merb.dir_for(:stylesheet) / 'sass'

      # Add SASS stylesheets to the load_path.
      sass_paths = (Sass::Plugin.options[:load_paths] ||= [template_location])
      sass_paths << File.join(kin, 'stylesheets')
    end
  end

  # Merb::Plugins.add_rakefiles "kin/merbtasks"
end
