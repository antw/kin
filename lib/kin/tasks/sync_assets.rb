namespace :kin do
  desc 'Copies the Kin stylesheets and javascripts to your app directory'
  task :copy_assets do
    puts ''

    [[:sass, 'stylesheets'], [:js, 'javascripts']].each do |(type, dir)|
      # Create directories in the app, if they don't already exist.
      unless File.exists?(path_for(type))
        nice_path = path_for(type).sub(/^#{Regexp.escape(Merb.root)}\/?/, '')
        puts "Creating directory: #{nice_path}"
        FileUtils.mkdir_p(path_for(type))
      end

      # Copy across files.
      assets = File.expand_path(File.join(
        File.dirname(__FILE__), '..', 'assets', dir, "*.#{type}"))

      Dir[assets].each do |file|
        puts "Copying asset: #{file.split(/\//).last}"
        FileUtils.cp(file, path_for(type))
      end
    end

    puts ''
  end

  def path_for(type)
    type == :sass ? sass_path : js_path
  end

  ##
  # Returns the SASS path for the current Merb application.
  #
  def sass_path
    sass_template_location =
      Merb::Plugins.config[:sass][:template_location] ||
      File.join(Merb.dir_for(:stylesheet), 'sass')

    File.join(sass_template_location, 'kin')
  end

  ##
  # Returns the JS path for the current Merb application.
  #
  def js_path
    File.join(Merb.dir_for(:javascript), 'kin')
  end
end
