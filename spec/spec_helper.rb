$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'merb-core'
require File.join(File.dirname(__FILE__), '..', 'lib', 'potion')

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
