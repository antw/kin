# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{potion}
  s.version = "0.1.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anthony Williams"]
  s.date = %q{2009-07-07}
  s.description = %q{Components commonly used in Showcase which can be applied to other projects.}
  s.email = %q{anthony@ninecraft.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    "LICENSE",
     "README",
     "Rakefile",
     "VERSION.yml",
     "lib/potion.rb",
     "lib/potion/form_builder.rb",
     "lib/potion/masthead.rb",
     "lib/potion/merbtasks.rb",
     "lib/potion/nav.rb",
     "lib/potion/stylesheets/forms.sass",
     "spec/fixture/app/controllers/application.rb",
     "spec/fixture/app/controllers/exceptions.rb",
     "spec/fixture/app/controllers/form_builder_specs.rb",
     "spec/fixture/app/controllers/masthead_specs.rb",
     "spec/fixture/app/controllers/nav_specs.rb",
     "spec/fixture/app/controllers/spec_controller.rb",
     "spec/fixture/app/helpers/global_helpers.rb",
     "spec/fixture/app/models/fake_model.rb",
     "spec/fixture/app/views/exceptions/not_acceptable.html.erb",
     "spec/fixture/app/views/exceptions/not_found.html.erb",
     "spec/fixture/app/views/form_builder_specs/bound_date_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_date_field_disabled.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_date_field_with_error.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_date_field_with_label.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_date_field_with_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_datetime_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_datetime_field_disabled.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_datetime_field_with_error.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_datetime_field_with_label.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_datetime_field_with_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_time_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_time_field_disabled.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_time_field_with_error.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_time_field_with_label.html.haml",
     "spec/fixture/app/views/form_builder_specs/bound_time_field_with_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/date_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/date_field_with_label.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_disabled.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_with_classes.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_with_date_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_with_datetime_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_with_label.html.haml",
     "spec/fixture/app/views/form_builder_specs/datetime_field_with_time_value.html.haml",
     "spec/fixture/app/views/form_builder_specs/label.html.haml",
     "spec/fixture/app/views/form_builder_specs/label_with_note.html.haml",
     "spec/fixture/app/views/form_builder_specs/label_with_note_in_parens.html.haml",
     "spec/fixture/app/views/form_builder_specs/label_with_requirement.html.haml",
     "spec/fixture/app/views/form_builder_specs/time_field.html.haml",
     "spec/fixture/app/views/form_builder_specs/time_field_with_label.html.haml",
     "spec/fixture/app/views/layout/application.html.erb",
     "spec/fixture/app/views/layout/masthead.html.haml",
     "spec/fixture/app/views/masthead_specs/all.html.haml",
     "spec/fixture/app/views/masthead_specs/border.html.haml",
     "spec/fixture/app/views/masthead_specs/escaping.html.haml",
     "spec/fixture/app/views/masthead_specs/no_border.html.haml",
     "spec/fixture/app/views/masthead_specs/no_extras.html.haml",
     "spec/fixture/app/views/masthead_specs/no_subtitles.html.haml",
     "spec/fixture/app/views/masthead_specs/right_subtitle.html.haml",
     "spec/fixture/app/views/masthead_specs/right_title.html.haml",
     "spec/fixture/app/views/masthead_specs/subtitle.html.haml",
     "spec/fixture/app/views/masthead_specs/with_css_classes.html.haml",
     "spec/fixture/app/views/masthead_specs/with_links.html.haml",
     "spec/fixture/app/views/masthead_specs/with_no_escape.html.haml",
     "spec/fixture/app/views/nav_specs/_guarded.html.haml",
     "spec/fixture/app/views/nav_specs/content_injection.html.haml",
     "spec/fixture/app/views/nav_specs/escaped_content_injection.html.haml",
     "spec/fixture/app/views/nav_specs/generic_nav.html.haml",
     "spec/fixture/app/views/nav_specs/guard_with_all_params.html.haml",
     "spec/fixture/app/views/nav_specs/guard_with_single_param.html.haml",
     "spec/fixture/app/views/nav_specs/guard_without_param.html.haml",
     "spec/fixture/app/views/nav_specs/item_with_title.html.haml",
     "spec/fixture/app/views/nav_specs/item_without_title.html.haml",
     "spec/fixture/app/views/nav_specs/multiple_injection.html.haml",
     "spec/fixture/app/views/nav_specs/resource_url.html.haml",
     "spec/fixture/app/views/nav_specs/resource_url_without_resource.html.haml",
     "spec/fixture/app/views/nav_specs/show_resource_url.html.haml",
     "spec/fixture/app/views/nav_specs/with_custom_formatter.html.haml",
     "spec/fixture/config/environments/development.rb",
     "spec/fixture/config/environments/production.rb",
     "spec/fixture/config/environments/rake.rb",
     "spec/fixture/config/environments/staging.rb",
     "spec/fixture/config/environments/test.rb",
     "spec/fixture/config/init.rb",
     "spec/fixture/config/rack.rb",
     "spec/fixture/config/router.rb",
     "spec/fixture/public/images/merb.jpg",
     "spec/fixture/public/stylesheets/master.css",
     "spec/form_builder_spec.rb",
     "spec/masthead_spec.rb",
     "spec/nav_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Components commonly used in Showcase which can be applied to other projects.}
  s.test_files = [
    "spec/fixture/app/controllers/application.rb",
     "spec/fixture/app/controllers/exceptions.rb",
     "spec/fixture/app/controllers/form_builder_specs.rb",
     "spec/fixture/app/controllers/masthead_specs.rb",
     "spec/fixture/app/controllers/nav_specs.rb",
     "spec/fixture/app/controllers/spec_controller.rb",
     "spec/fixture/app/helpers/global_helpers.rb",
     "spec/fixture/app/models/fake_model.rb",
     "spec/fixture/config/environments/development.rb",
     "spec/fixture/config/environments/production.rb",
     "spec/fixture/config/environments/rake.rb",
     "spec/fixture/config/environments/staging.rb",
     "spec/fixture/config/environments/test.rb",
     "spec/fixture/config/init.rb",
     "spec/fixture/config/rack.rb",
     "spec/fixture/config/router.rb",
     "spec/form_builder_spec.rb",
     "spec/masthead_spec.rb",
     "spec/nav_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
