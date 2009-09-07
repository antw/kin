require 'merb-helpers'

# Make sure we're running inside Merb.
if defined?(Merb::Plugins)
  kin = File.expand_path(File.join(File.dirname(__FILE__), 'kin'))

  require File.join(kin, 'core_ext', 'date')
  require File.join(kin, 'core_ext', 'string')
  require File.join(kin, 'core_ext', 'time')

  require File.join(kin, 'configurable')
  require File.join(kin, 'form_builder')
  require File.join(kin, 'masthead')
  require File.join(kin, 'nav')

  Merb::Plugins.add_rakefiles(File.join(kin, 'tasks', 'sync_assets'))
  Merb::Plugins.add_rakefiles(File.join(kin, 'tasks', 'sprites'))

  # Default nav formatter. Can be overridden in an after_app_loads block, or
  # on a case-by-case basis in +display_navigation+.
  Merb::Plugins.config[:kin] = {
    :nav_formatter => Kin::Nav::Formatters::Basic
  }

  Merb::BootLoader.after_app_loads do
    # Add default time formats.
    unless Time.formats.include?(:full)
      Time.add_format(:full, '%A %d %B, %H:%M')
    end

    unless Time.formats.include?(:date_only)
      Time.add_format(:date_only, '%A %d %B')
    end

    unless Time.formats.include?(:date_with_year)
      Time.add_format(:date_with_year, '%d %B %Y')
    end

    # After the application loads, see if there is a config/navigation.rb file
    # to initialize the nav instances.
    nav_rb = File.join(Merb.dir_for(:config), 'navigation.rb')
    load(nav_rb) if File.exists?(nav_rb)
  end
end
