require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

# Nav ========================================================================

describe Kin::Nav do

  after(:each) do
    Kin::Nav.reset!
  end

  # ----------
  # initialize

  describe '#initialize' do
    it 'should set the Nav name to the one supplied' do
      Kin::Nav::Menu.new(:test).name.should == :test
    end

    it 'should typecast the name to a symbol' do
      Kin::Nav::Menu.new('test').name.should == :test
    end
  end

  # -----
  # setup

  describe '#setup' do
    it 'should yield something which can build a menu' do
      Kin::Nav.setup(:test) do |m|
        m.respond_to?(:add).should be_true
        m.add(:nav, 'Text').respond_to?(:title).should be_true
        m.add(:nav, 'Text').respond_to?(:url).should be_true
        m.add(:nav, 'Text').respond_to?(:resource).should be_true
        m.add(:nav, 'Text').respond_to?(:guard).should be_true
      end
    end

    it 'should freeze the returned Nav and items' do
      Kin::Nav.setup(:test).should be_frozen
      Kin::Nav.setup(:test).items.should be_frozen
    end

    it 'should register the nav' do
      Kin::Nav.get(:test).should be_nil
      Kin::Nav.setup(:test)
      Kin::Nav.get(:test).should be_kind_of(Kin::Nav::Menu)
    end
  end

  # ----------------------
  # some integration tests

  describe '(integration)' do
    before(:all) do
      @nav = Kin::Nav.setup(:test) do |nav|
        nav.add(:home, 'Home')
        nav.add(:second, 'Second item')
        nav.add(:another, 'Another item')
      end
    end

    it 'should have the correct number of nav items' do
      @nav.items.should have(3).items
    end

    it 'should order the items in the same order as they are added' do
      @nav.items[0].id.should == :home
      @nav.items[1].id.should == :second
      @nav.items[2].id.should == :another
    end
  end

  # -------
  # to_html

  describe '#to_html' do
    before(:each) do
      @c = NavSpecs.new(Merb::Request.new({}))
    end

    it 'should render all the items' do
      html = @c.render(:generic_nav)
      html.should have_selector('#nav_home')
      html.should have_selector('#nav_products')
    end

    it 'should set the correct item as active' do
      pending do
        html = @c.render(:generic_nav)
        html.should have_selector('#nav_home.active')
        html.should_not have_selector('#nav_products.active')
      end
    end

    it 'should include the item label' do
      html = @c.render(:generic_nav)
      html.should have_selector('#nav_home a:contains("Home")')
      html.should have_selector('#nav_products a:contains("Products")')
    end

    it 'should include the item url' do
      html = @c.render(:generic_nav)
      html.should have_selector('#nav_home a[href="/"]')
      html.should have_selector('#nav_products a[href="/products"]')
    end

    # -----------------------
    # with a custom formatter

    describe 'with a custom formatter' do
      it 'should use the custom formatter' do
        formatter = mock('Custom formatter')
        formatter.should_receive(:to_html)

        ::CustomFormatter = mock('Custom formatter class')
        ::CustomFormatter.should_receive(:new).and_return(formatter)

        begin
          @c.render(:with_custom_formatter)
        ensure
          Object.send(:remove_const, :CustomFormatter)
        end
      end
    end

    # ------
    # titles

    describe 'when an item has a title' do

      before(:each) do
        @html = @c.render(:item_with_title)
      end

      it 'should use the title in the anchor' do
        @html.should have_selector('#nav_title a[title="My item title"]')
      end

      it 'should use the title in preference over injected content' do
        @html.should have_selector(
          '#nav_inject_title a[title="My item title"]')
      end

    end

    describe 'when the item has no title' do
      it 'should use the label as the anchor title' do
        @c.render(:item_without_title).should have_selector(
          '#nav_no_title a[title="Has no title"]')
      end
    end

    # -----------------
    # content injection

    describe 'when using content injection' do

      it 'should permit content injection using a hash' do
        @c.render(:content_injection).should have_selector(
          '#nav_injection:contains("Has content injection")')
      end

      it 'should permit injection of multiple parameters using an array' do
        @c.render(:multiple_injection).should have_selector(
          '#nav_injection:contains("Has content injection")')
      end

      it 'should inject the content into the title' do
        @c.render(:content_injection).should have_selector(
          '#nav_injection a[title="Has content injection"]')
      end

      it 'should escape the given content' do
        @c.render(:escaped_content_injection).should =~
          />\s*Has &amp; injection\s*</
      end

    end

    # -----------------------------------
    # generating resource URLs at runtime

    describe 'when an item generates a URL at runtime' do
      it 'should generate the URL using a route' do
        expected = Merb::Router.url(:edit_fake_model, :id => 1337)
        @c.render(:resource_url).should have_selector(
          '#nav_resource a[href="%s"]' % expected)
      end

      it 'should correctly create :show URLs' do
        expected = Merb::Router.url(:fake_model, :id => 1337)
        @c.render(:show_resource_url).should have_selector(
          '#nav_resource a[href="%s"]' % expected)
      end

      it 'should raise a MissingResource if no resource is given' do
        lambda do
          @c.render(:resource_url_without_resource)
        end.should raise_error(Kin::Nav::MissingResource)
      end
    end

    # ----------------
    # guard conditions

    describe 'when some items have a guard condition' do

      before(:each) do
        @c = NavSpecs.new(Merb::Request.new({}))
      end

      describe 'and no :guard is given to #to_html' do
        before(:each) do
          @html = @c.render(:guard_without_param)
        end

        it 'should include non-guarded nav items' do
          @html.should have_selector('#nav_home')
          @html.should have_selector('#nav_not_guarded')
        end

        it 'should not include the guarded nav items' do
          @html.should_not have_selector('#nav_guard_one')
          @html.should_not have_selector('#nav_guard_two')
          @html.should_not have_selector('#nav_guard_three')
        end
      end

      describe 'and a single guard condition is given to #to_html' do
        before(:each) do
          @html = @c.render(:guard_with_single_param)
        end

        it 'should include the non-guarded nav items' do
          @html.should have_selector('#nav_home')
          @html.should have_selector('#nav_not_guarded')
        end

        it 'should include the specified guarded items' do
          @html.should have_selector('#nav_guard_one')
          @html.should have_selector('#nav_guard_two')
        end

        it 'should not include the unspecified guarded items' do
          @html.should_not have_selector('#nav_guard_three')
        end
      end

      describe 'and several guard conditions are given to #to_html' do
        before(:each) do
          @html = @c.render(:guard_with_all_params)
        end

        it 'should include the non-guarded nav items' do
          @html.should have_selector('#nav_home')
          @html.should have_selector('#nav_not_guarded')
        end

        it 'should include the specified guarded items' do
          @html.should have_selector('#nav_guard_one')
          @html.should have_selector('#nav_guard_two')
          @html.should have_selector('#nav_guard_three')
        end
      end

    end # guarded #to_html tests.

    # ------------
    # active items

    describe 'where active items are defined' do
      it 'should make the correct item active with a matching pair' do
        @c.stub!(:action_name).and_return('specific_active')

        html = @c.render(:active)

        html.should_not have_selector('#nav_home.active')
        html.should_not have_selector('#nav_generic.active')
        html.should_not have_selector('#nav_controller.active')
        html.should have_selector('#nav_specific.active')
        html.should_not have_selector('#nav_invalid_generic.active')
        html.should_not have_selector('#nav_invalid_controller.active')
        html.should_not have_selector('#nav_invalid_specific.active')
      end

      it 'should make the correct item active with a matching controller' do
        @c.stub!(:action_name).and_return('nope')

        html = @c.render(:active)

        html.should_not have_selector('#nav_home.active')
        html.should_not have_selector('#nav_generic.active')
        html.should have_selector('#nav_controller.active')
        html.should_not have_selector('#nav_specific.active')
        html.should_not have_selector('#nav_invalid_generic.active')
        html.should_not have_selector('#nav_invalid_controller.active')
        html.should_not have_selector('#nav_invalid_specific.active')
      end

      it 'should make the correct item active with a generic pair' do
        @c.stub!(:controller_name).and_return('nope')
        @c.stub!(:action_name).and_return('specific_active')

        html = @c.render(:template => 'nav_specs/active')

        html.should_not have_selector('#nav_home.active')
        html.should have_selector('#nav_generic.active')
        html.should_not have_selector('#nav_controller.active')
        html.should_not have_selector('#nav_specific.active')
        html.should_not have_selector('#nav_invalid_generic.active')
        html.should_not have_selector('#nav_invalid_controller.active')
        html.should_not have_selector('#nav_invalid_specific.active')
      end
    end

  end # to_html specs

end
