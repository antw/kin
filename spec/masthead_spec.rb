require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

# Masthead::Builder Specs ======================================================

describe 'masthead builder setter', :shared => true do
  it 'should set the attribute if a value is given' do
    @builder.send(@method, 'my_value').should == 'my_value'
  end

  it 'should not change the attribute value if nil is given' do
    @builder.send(@method, 'my_value')
    @builder.send(@method).should == 'my_value'
    @builder.send(@method, nil).should == 'my_value'
  end

  it 'should set the extra options' do
    @builder.send(@method, 'my_value', { :link => '/' })
    @builder.options[@method].should == { :link => '/' }
  end
end

describe Kin::Masthead::Builder do
  before(:each) do
    @builder = Kin::Masthead::Builder.new
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
      @c.render(:right_subtitle).should have_selector('.extra .main') do |main|
        main.to_xhtml.should include('&#xA0;') # Unicode non-breaking space.
      end
    end

    # Extras div.

    it 'should not include an "extra" div if no right titles are set' do
      @c.render(:no_extras).should_not have_selector('.extra')
    end

    it 'should include an "extra" div if a right title is set' do
      @c.render(:right_title).should have_selector('.extra')
    end

    it 'should include an "extra" div if a right subtitle is set' do
      @c.render(:right_subtitle).should have_selector('.extra')
    end

    # Subtitles.

    it 'should not include subtitles when no subtitles are set' do
      @c.render(:no_subtitles).should_not have_selector('.subtitle')
    end

    it 'should include a subtitle if a subtitle is set' do
      @c.render(:subtitle).should have_selector('.subtitle')
    end

    it 'should include a right subtitle if a right subtitle is set' do
      @c.render(:right_subtitle).should have_selector('.extra .subtitle')
    end

    # Links.

    it 'should add links to fields when a :link option is present' do
      links = @c.render(:with_links)
      links.should have_selector('h1 a[href="/title"]')
      links.should have_selector('.subtitle a[href="/subtitle"]')
      links.should have_selector('.main a[href="/right_title"]')
      links.should have_selector('.subtitle a[href="/right_subtitle"]')
    end

    # Custom CSS classes.

    it 'should add extra CSS classes to fields when a :class option is present' do
      css_classes = @c.render(:with_css_classes)
      css_classes.should have_selector('h1.my_title')
      css_classes.should have_selector('.subtitle.my_subtitle')
      css_classes.should have_selector('.main.my_right_title')
      css_classes.should have_selector('.subtitle.my_right_subtitle')
    end

    # Escaping

    it 'should escape values by default' do
      escaped = @c.render(:escaping)

      escaped.should have_selector('h1') do |h1|
        h1.to_s.should =~ /&amp;/
      end

      escaped.should have_selector('.details .subtitle') do |subtitle|
        subtitle.to_s.should =~ /&amp;/
      end

      escaped.should have_selector('.main') do |right_title|
        right_title.to_s.should =~ /&amp;/
      end

      escaped.should have_selector('.extra .subtitle') do |right_subtitle|
        right_subtitle.to_s.should =~ /&amp;/
      end
    end

    # No escaping.

    it 'should not escape fields when a :no_escape option is set' do
      escape = @c.render(:with_no_escape)

      escape.should have_selector('h1') do |h1|
        h1.to_s.should =~ /<strong>/
      end

      escape.should have_selector('.details .subtitle') do |subtitle|
        subtitle.to_s.should =~ /&lt;strong&gt;/
      end

      escape.should have_selector('.main') do |right_title|
        right_title.to_s.should =~ /&lt;strong&gt;/
      end
    end
  end

end
