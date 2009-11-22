require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Kin::Configurable, 'when mixed in to a module' do

  before(:each) do
    @configurable = Module.new { extend Kin::Configurable }
  end

  # ---------
  # configure

  it 'should respond to #configure' do
    @configurable.should respond_to(:configure)
  end

  it 'should set attribute values' do
    @configurable.configure do |c|
      c.hello = 'world'
      c.array = ['yep']
    end

    @configurable.config.hello.should == 'world'
    @configurable.config.array.should == ['yep']
  end

  it 'should raise NoMethodError when accessing an undefined setting' do
    lambda { @configurable.invalid }.should raise_error(NoMethodError)
  end

  # ------
  # config

  it 'should respond to #config' do
    @configurable.should respond_to(:config)
  end

end