require 'merb-helpers'

# Make sure we're running inside Merb.
if defined?(Merb::Plugins)
  kin = File.expand_path(File.join(File.dirname(__FILE__), 'kin'))

  require File.join(kin, 'form_builder')
  require File.join(kin, 'masthead')
  require File.join(kin, 'nav')

  Merb::Plugins.add_rakefiles(File.join(kin, 'tasks', 'sync_assets'))

  # Default nav formatter. Can be overridden in an after_app_loads block, or
  # on a case-by-case basis in +display_navigation+.
  Merb::Plugins.config[:kin] = { :nav_formatter => Kin::Nav::BasicFormatter }
end
