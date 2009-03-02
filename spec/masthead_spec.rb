require File.join(File.dirname(__FILE__), 'spec_helper.rb')

# Masthead::Builder Specs ======================================================

describe 'masthead builder setter', :shared => true do
  it 'should set the attribute if a value is given' do
    @builder.send(@method, 'my_value').should == 'my_value'
  end

  it 'should escape the value' do
    @builder.send(@method, '&').should == '&amp;'
  end

  it 'should not change the attribute value if nil is given' do
    @builder.send(@method, 'my_value')
    @builder.send(@method).should == 'my_value'
    @builder.send(@method, nil).should == 'my_value'
  end
end

describe Showcase::Common::Masthead::Builder do
  before(:each) do
    @builder = Showcase::Common::Masthead::Builder.new
  end

  # -------
  # Setters

  describe '#title' do
    before(:each) { @method = :title }
    it_should_behave_like 'masthead builder setter'
  end

  describe '#subtitle' do
    before(:each) { @method = :subtitle }
    it_should_behave_like 'masthead builder setter'
  end

  describe '#right_title' do
    before(:each) { @method = :right_title }
    it_should_behave_like 'masthead builder setter'
  end

  describe '#right_subtitle' do
    before(:each) { @method = :right_subtitle }
    it_should_behave_like 'masthead builder setter'
  end

  # -----
  # build

  describe '#build' do
    it 'should set the masthead titles' do
      @builder.build do |m|
        m.title('Title')
        m.subtitle('Subtitle')
        m.right_title('Right title')
        m.right_subtitle('Right subtitle')
      end

      @builder.title.should == 'Title'
      @builder.subtitle.should == 'Subtitle'
      @builder.right_title.should == 'Right title'
      @builder.right_subtitle.should == 'Right subtitle'
    end
  end

  # -------
  # to_html

  describe '#to_html' do
    before(:each) do
      @c = MastheadSpecs.new(Merb::Request.new({}))
    end

    # Fields

    it 'should render the title' do
      @c.render(:all).should have_selector('.details h1:contains("Title")')
    end

    it 'should render the subtitle' do
      @c.render(:all).should have_selector(
        '.details .subtitle:contains("Subtitle")')
    end

    it 'should render the right title' do
      @c.render(:all).should have_selector(
        '.extra .main:contains("Right title")')
    end

    it 'should render the right title' do
      @c.render(:all).should have_selector(
        '.extra .subtitle:contains("Right subtitle")')
    end
    
    it 'should render an empty right title when no right title is set, but ' +
       'a right subtitle is set' do
      @c.render(:right_subtitle).should have_selector('.extra .main')
    end

    # Extras div.

    it 'should not include an "extra" div if no right titles are set' do
      @c.render(:no_extras).should_not have_selector('.extra')
    end

    it 'should include en "extra" div if a right title is set' do
      @c.render(:right_title).should have_selector('.extra')
    end

    it 'should include an "extra" div if a right subtitle is set' do
      @c.render(:right_subtitle).should have_selector('.extra')
    end

    # Border.

    it 'should not have a "no_border" class by default' do
      @c.render(:border).should_not have_selector('.no_border')
    end

    it 'should have a "no_border" class when no_border = true' do
      @c.render(:no_border).should have_selector('.no_border')
    end
  end

end

# Masthead::Helper Specs =====================================================

describe 'Masthead helper mixin' do
  include Showcase::Common::Masthead::Helper

  describe '#masthead' do
    it 'should pass along the :no_border option' do
      masthead(:no_border => true) { |_| }
      masthead_builder.no_border.should be_true
    end

    it 'should pass the block along to #build' do
      masthead { |m| m.title('Title') }
      masthead_builder.title.should == 'Title'
    end
  end

  describe '#masthead_builder' do
    it 'should return the same instance each time' do
      masthead_builder.object_id.should == masthead_builder.object_id
    end
  end
end
