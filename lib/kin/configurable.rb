module Kin
  ##
  # Adds configuration to a module. Useful for creating application-wide
  # settings.
  #
  # @example
  #   module MyApplication
  #     extend Kin::Configurable
  #   end
  #
  module Configurable
    ##
    # Holds the configuration for a module.
    #
    class Config

      def initialize
        @config = {}
      end

      ##
      # Custom method_missing to define setter and getter methods when a
      # setter method is called.
      #
      def method_missing(method, *args)
        if method.to_s =~ /^(.*)=$/
          instance_eval <<-RUBY
            def #{$1}=(value)          # def setting=(value)
              @config[:#{$1}] = value  #   @config[:setting] = value
            end                        # end

            def #{$1}                  # def setting
              @config[:#{$1}]          #   @config[:setting]
            end                        # end
          RUBY

          @config[$1.to_sym] = args.first
        else
          super
        end
      end

    end


    ##
    # Provides a handy block notation for configuring your app/object.
    #
    # @yield [Kin::Configurable::Config] The config object.
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
    # @return [Kin::Configurable::Config]
    #
    def config
      @@_config ||= Config.new
    end
  end
end
