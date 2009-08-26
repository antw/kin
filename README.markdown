# Kin

Kin is a small collection of common components extracted from my Merb
applications. Rather than duplicating functionality in several apps it is
instead all contained in this one gem. As a result, the contents are rather
opinionated (such as extending some core classes and adding date/time
formats), and will be of limited use to others for the moment. In fact, Kin is
only publicly available since one of the apps which uses it -- Showcase -- is
open source.

Still, do what you want with it; MIT License and all that... :)

#### Assets

kin.js which adds some UI helpers on top of Mootools, and _forms.sass
containing shared form styles.

#### Some core class extensions

Boo, hiss, etc, etc.

#### Kin::Configurable

A wrapper around configatron used for configuring apps (see config/showcase.rb
in the Showcase application).

#### Kin::Form

A custom form builder which extends the one from the merb-helpers gem. Adds
support for date_field, time_field and datetime_field. Also included is a
tweaked label helper which will add span.req around asterisks, and span.note
around text which is in parenthesis.

#### Kin::Nav

Allows for easily building tabbed navigation, selecting active tabs, linking
to resources, and guarding tabs from user who lack sufficient permission.

#### Kin::Masthead

Creates the mastheads used in Showcase which contains the page title, and
other various details.
