module Kin
  ##
  # Provides a wrapper around Configatron, adding #configure and #config
  # methods to extended modules.
  #
  # @example
  #   module MyApplication
  #     extend Kin::Configurable
  #   end
  #
  module Configurable
    def self.extended(*args)
      # Load configatron on-demand.
      require 'configatron'
    end

    ##
    # Provides a handy block notation for configuring your app/object.
    #
    # @yield [Configatron::Store] The config object.
    #
    # @example
    #   MyObj.configure do |c|
    #     c.auth.site_key = 'a8ecf9ac57d287e41'
    #   end
    #
    def configure
      yield config
    end

    ##
    # Returns the configuration.
    #
    # @return [Configatron::Store]
    #
    def config
      @@_config ||= Configatron::Store.new
    end
  end
end
