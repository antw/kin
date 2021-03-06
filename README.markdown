# Kin

Kin is a small collection of common components extracted from my Merb
applications. Rather than duplicating functionality in several apps it is
instead all contained in this one gem. Some parts of this Gem are very
general-purpose (such as the navigation helpers and sprite generators), and
may be extracted into their own libraries in the future. Other aspects of Kin
are very specific to my apps, and likely to be of limited use elsewhere.

Still, do what you want with it; MIT License and all that... :)

### Contents

Kin contains:

  * Navigation helpers,
  * Icon sprite generators,
  * A form builder with date helpers,
  * Javascripts (built on top of MooTools), stylesheets, and images to create
    reusable UI widgets,
  * Application configuration with Kin::Configurable.

### Compatibility

Tested on Ruby 1.8.6p383, Ruby 1.8.7p174, and Ruby 1.9.1p243. Presently, Kin
supports Merb 1.0 and Merb Git head (1.1). Support for Rails will likely be
added once 3.0 begins release candidature.

## Navigation Helpers

Kin::Nav contains a number of classes to aid in creating navigation elements
on HTML pages. For example:

    <ul>
      <li id="nav_home" class="active">
        <a href="/" title="Return to the home page">Home</a>
      </li>
      <li id="nav_products">
        <a href="/products" title="Products">Products</a>
      </li>
      <li id="nav_contact">
        <a href="/contact" title="Contact Us">Contact Us</a>
      </li>
    </ul>

This sort of UI pattern can be seen on just about every website, and Kin::Nav
aims to simplify the creation of these elements. By default, Kin assumes that
your nav menus are declared in config/navigation.rb. The above HTML fragment
would be generated by the following definition:

    Kin::Nav.setup(:default) do |menu|
      menu.add(:home, 'Home') do |item|
        item.url       '/'
        item.active_on '*/*'
        item.title     'Return to the home page'
      end

      menu.add(:products, 'Products') do |item|
        item.url       '/products'
        item.active_on 'products/*'
      end

      menu.add(:contact, 'Contact Us') do |item|
        item.url       '/contact'
        item.active_on 'contact/new'
      end
    end

This creates a very basic menu with three items. A "Contact Us" item which
will have the "active" CSS class applied on the 'new' action of the 'contact'
controller, a "Products" item active on any action belonging to the 'products'
controller, and a "Home" item which will be active on any other
controller/action pair.

### Resources

Kin::Nav allows you to define items which, rather than having a static URL,
use a resource to generate a URL. For example:

    Kin::Nav.setup(:product) do |menu|
      menu.add(:settings, 'Settings') do |item|
        item.resource  :edit
        item.active_on 'products/{edit,update}'
        item.title     "Edit this product's settings"
      end
    end

    # Display the navigation.
    display_navigation :product, :resource => Product.first

In this example, we pass a Product instance to the display\_navigation helper
so the menu will call `Merb::Router.resource(product, :edit)`, and use that as
the URL for the item.

### Dynamic content

You might sometimes need to add extra content to an item from a controller or
action; this can be done with the "inject" option.

    Kin::Nav.setup(:stuff) do |menu|
      menu.add(:comments, 'Comments (%d)') do |item|
        item.url  '/comments'
        item.title 'Comments'
      end

      menu.add(:you, '%s (%d)') do |item|
        item.url   '/you'
        item.title 'Your profile'
      end
    end

    # Display the navigation.
    display_navigation :stuff, :inject => {
      :comments => 6, :messages => ["antw", 1]
    }

The `inject` option expects a hash -- with each key matching an item in the
menu in to which you wish to add content, and a value which is provided to
String#%.

    <ul>
      <li id="nav_comments" >
        <a href="/" title="Comments">Comments (6)</a>
      </li>
      <li id="nav_you">
        <a href="/you" title="Your profile">antw (1)</a>
      </li>
    </ul>

### Hiding items from certain users ("guards")

For when you need to hide an item from users (such as items which you only
want to show to administrators), Kin provides the `guard` option.

    Kin::Nav.setup(:has_guards) do |menu|
      menu.add(:home, 'Home') do |item|
        item.url   '/'
      end

      menu.add(:settings, 'Settings') do |item|
        item.url   '/settings'
        item.guard :admin
      end
    end

    # Display the navigation.
    display_navigation :guarded, :guards => { :admin => session.user.admin? }

The above example creates a navigation menu with two items; the `settings`
item will only be shown to users for whom `session.user.admin?` evaluates to
true. Multiple items can share the same guard (i.e. a menu could have several
items which use the `admin` guard condition).

    display_navigation :stuff, :guards => { :admin => true }

    <ul>
      <li id="nav_home">
        <a href="/" title="Home">Home</a>
      </li>
      <li id="nav_settings">
        <a href="/settings" title="Settings">Settings</a>
      </li>
    </ul>

... while ...

    display_navigation :stuff, :guards => { :admin => false }

    <ul>
      <li id="nav_home" ><a href="/" title="Home">Home</a></li>
    </ul>

## Icon Sprite Generators

As broadband Internet connections have become somewhat ubiquitous (at least in
Europe and N. America), many have sought to improve web-page loading by
reducing the number of HTTP requests required to load a pege. One means of
accomplishing this is by compressing small -- or commonly-loaded -- images
into [single, larger sprites](http://www.alistapart.com/articles/sprites).

Kin provides `Kin::Sprites` which compresses multiple 16x16 pixel icons into
single files, and a generates a SASS partial to make using these sprites
simple.

A rake task, `kin:sprites`, is provided to simplify creation of sprites, and
makes two assumptions:

  * That you have a sprites.yml in your config path which defines the sprites,
    and the icons which should be included in each one;
  * That the source 16x16px icons can be found in sprites/src in your images
    path.

In a typical Merb app, your directory structure should look a little like
this:

    - app
    - config
      - sprites.yml  # <- Defines sprites.
    - public
      - images
        - sprites    # <- Generated sprites end up here.
          - src      # <- 16x16 source files here.
    - spec
    - tasks

A sprites.yml containing two sprites may look like this:

    ---
      main:
        - guest
        - set
        - timeline

      set:
        - set-edit
        - set-icon

Running `rake kin:sprites` would create two sprites in the sprites/ directory:
main.png (which contains src/guest.png, src/set.png, and src/timeline.png),
and set.png (containing src/set-edit.png and src/set-icon.png).

![main.png](http://github.com/antw/kin/raw/b49504d291527e7700403fe8cfae7403f4a40d58/docs/sprite-example.png "main.png")

### SASS partial

The catch with sprites is that it forces you to calculate CSS background
positions every time you want to use it. "Is the set icon -40px or -80px?"
This becomes a tricky question to answer if you have a large number of icons
in your sprite, and will break your UI if you reorder the icons and forget to
update the CSS.

To solve this, `rake kin:sprites` also generates a SASS partial named
\_sprites.sass, and saves it to your stylesheets/sass directory.

For each sprite you define, a SASS mixin will be created with the same name
(and "-icon" appended). This mixin accepts an argument: the name of the icon
you wish to be displayed. To use the above main.png example, if we wish to
show the sets icon from the main.png sprite, we can do this in our SASS
stylesheet:

    .an_element
      +main-icon("sets")

This automatically adds the correct background image and background position
to the CSS element. Not only does this make using icon sprites easy, since you
don't need to remember (or calculate!) background positions each time you want
to use one, but you can change your sprite at will without your SASS needing
to be updated.

    .an_element {
      background: url(/images/sprites/main.png) 0 -40px no-repeat;
    }

Note: The partial uses features only available in HAML/SASS 2.2 and later.

### Cached sprites

The `kin:sprites` rake task keeps track of the contents of each sprite (in a
hidden .hashes file in the sprites/ directory), so that a sprite will only be
regenerated if you have changed it's definition in sprites.yml. This leaves
you free to further process each image (with OptiPNG for example) knowing it
won't be overwritten next time you run the rake task. If you wish to overwrite
a sprite, even if it hasn't changed since last time you ran the task, you can
either delete it and run `rake kin:sprites`, or run `rake kin:sprites:force`
to regenerate all of the sprites.

## Form builder

Kin::Form::Builder is a custom form builder which extends the one included
with the merb-helpers gem. It adds support for date\_field, time\_field and
datetime\_field. Also included is a tweaked label helper which will add
span.req around asterisks, and span.note around text which is in parenthesis.

## UI assets

kin.js adds some UI helpers on top of Mootools, and _forms.sass contains
shared form styles. Assets can be copied to your application with
`rake kin:copy-assets`.

## Application configuration

Allows any object to have a (public) configuration. Commonly used for
application configuration:

    module MyApplication
      extend Kin::Configurable
    end

Kin::Configurable provides an easy means of setting configuration.

    MyApplication.configure do |c|
      c.auth.site_key = "a8ecf9ac57d287e41"
    end

The setting defined above could then be retrieved with:

    MyApplication.config.auth.site_key
    # => "a8ecf9ac57d287e41"

## Core-class extensions

A handful of extensions are added to Date and Time to enable `fuzzy` date
formats ("today", "yesterday"). The String class is also tweaked to add a
`numericise` method (`"article".numericise(2) # => "2 articles"`).
