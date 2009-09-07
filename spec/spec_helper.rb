$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'merb-core'
require File.join(File.dirname(__FILE__), '..', 'lib', 'kin')

use_template_engine :haml
Merb.disable(:initfile)

Merb.start_environment(
  :testing     => true,
  :adapter     => 'runner',
  :environment => 'test',
  :merb_root   => File.dirname(__FILE__) / 'fixture',
  :log_file    => File.dirname(__FILE__) / 'merb_test.log'
)

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Module.new do
    ##
    # Returns a path to the fixture directory. Any additional string
    # parameters will be joined with the path.
    #
    def fixture_path(*dirs)
      File.join(File.dirname(__FILE__), 'fixture', *dirs)
    end

    ##
    # Returns a path to the tmp/spec folder. Any additional string
    # parameters will be joined with the path.
    #
    def tmp_path(*dirs)
      File.join(File.dirname(__FILE__), '..', 'tmp', 'spec', *dirs)
    end

    ##
    # Does exactly what it says on the tin.
    #
    def capture_stdout
      orig, $stdout = $stdout, StringIO.new

      begin
        yield
        return $stdout.string
      ensure
        $stdout = orig
      end
    end
  end)
end

##
# The following fake models are used in the form builder specs. The
# FakeColumn and FakeError classes are taken from merb-helpers, licensed
# with the MIT License.
#
class FakeErrors
  def initialize(model)
    @model = model
  end

  def on(name)
    name.to_s.include?("bad")
  end
end
