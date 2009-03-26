# Go to http://wiki.merbivore.com/pages/init-rb

# Specify a specific version of a dependency
# dependency "RedCloth", "> 3.0"

# use_orm :none
# use_test :rspec
use_template_engine :haml

Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper

  # cookie session store configuration
  c[:session_secret_key]  = '762e2ea1d85181886f940497264b7b0865820676'  # required for cookie session store
  c[:session_id_key] = '_fixture_session_id' # cookie session id key, defaults to "_session_id"
end

dependency File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'potion')
