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

  describe 'and configuring' do
    it 'should yield the configatron instance' do
      @configurable.configure do |c|
        c.should be_kind_of(Configatron::Store)
      end
    end

    it 'should allow the setting of new attributes' do
      @configurable.configure do |c|
        c.hello = 'world'
        c.another.item = 'value'
      end

      @configurable.config.hello.should == 'world'
      @configurable.config.another.item.should == 'value'
    end
  end

  # ------
  # config

  it 'should respond to #config' do
    @configurable.should respond_to(:config)
  end

  describe 'and fetching the configuration' do
    it 'should yield a configatron instance' do
      @configurable.config.should be_kind_of(Configatron::Store)
    end
  end

end