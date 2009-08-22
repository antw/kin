require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Kin::Form::Builder do

  before(:each) do
    @c = FormBuilderSpecs.new(Merb::Request.new({}))
  end

  # Unbound Datetime Fields ==================================================

  describe 'unbound_datetime_field' do

    before(:each) do
      @rendered = @c.render(:datetime_field)
    end

    it 'should have a day field' do
      @rendered.should have_selector('input[id="publish_on_day"]')
      @rendered.should have_selector('input[name="publish_on[day]"]')
    end

    it 'should have a month field' do
      @rendered.should have_selector('input[id="publish_on_month"]')
      @rendered.should have_selector('input[name="publish_on[month]"]')
    end

    it 'should have a year field' do
      @rendered.should have_selector('input[id="publish_on_year"]')
      @rendered.should have_selector('input[name="publish_on[year]"]')
    end

    it 'should have a hour field' do
      @rendered.should have_selector('input[id="publish_on_hour"]')
      @rendered.should have_selector('input[name="publish_on[hour]"]')
    end

    it 'should have a minute field' do
      @rendered.should have_selector('input[id="publish_on_minute"]')
      @rendered.should have_selector('input[name="publish_on[minute]"]')
    end

    it 'should set the day field maxlength to 2' do
      @rendered.should have_selector('#publish_on_day[maxlength="2"]')
    end

    it 'should set the month field maxlength to 2' do
      @rendered.should have_selector('#publish_on_month[maxlength="2"]')
    end

    it 'should set the year field maxlength to 4' do
      @rendered.should have_selector('#publish_on_year[maxlength="4"]')
    end

    it 'should set the hour field maxlength to 2' do
      @rendered.should have_selector('#publish_on_hour[maxlength="2"]')
    end

    it 'should set the minute field maxlength to 2' do
      @rendered.should have_selector('#publish_on_minute[maxlength="2"]')
    end

    it 'should have the correct day label' do
      @rendered.should have_selector(
        '.field.day label[for="publish_on_day"]')
      @rendered.should have_selector('.field.day label:contains("DD")')
    end

    it 'should have the correct month label' do
      @rendered.should have_selector(
        '.field.month label[for="publish_on_month"]')
      @rendered.should have_selector('.field.month label:contains("MM")')
    end

    it 'should have the correct year label' do
      @rendered.should have_selector(
        '.field.year label[for="publish_on_year"]')
      @rendered.should have_selector('.field.year label:contains("YYYY")')
    end

    it 'should have the correct hour label' do
      @rendered.should have_selector(
        '.field.hour label[for="publish_on_hour"]')
      @rendered.should have_selector('.field.hour label:contains("HH")')
    end

    it 'should have the correct minute label' do
      @rendered.should have_selector(
        '.field.minute label[for="publish_on_minute"]')
      @rendered.should have_selector('.field.minute label:contains("MM")')
    end

    it 'should merge passed-in classes to the fields' do
      extra_classes = @c.render(:datetime_field_with_classes)

      extra_classes.should have_selector('#publish_on_day.one.two.text')
      extra_classes.should have_selector('#publish_on_month.one.two.text')
      extra_classes.should have_selector('#publish_on_year.one.two.text')
      extra_classes.should have_selector('#publish_on_hour.one.two.text')
      extra_classes.should have_selector('#publish_on_minute.one.two.text')
    end

    it 'should set no values for any field when value=nil' do
      @rendered.should have_selector('#publish_on_day[value=""]')
      @rendered.should have_selector('#publish_on_month[value=""]')
      @rendered.should have_selector('#publish_on_year[value=""]')
      @rendered.should have_selector('#publish_on_hour[value=""]')
      @rendered.should have_selector('#publish_on_minute[value=""]')
    end

    it 'should set the value of each field correctly when given a Time' do
      time_val = @c.render(:datetime_field_with_time_value)

      time_val.should have_selector('#publish_on_day[value="28"]')
      time_val.should have_selector('#publish_on_month[value="2"]')
      time_val.should have_selector('#publish_on_year[value="2009"]')
      time_val.should have_selector('#publish_on_hour[value="1"]')
      time_val.should have_selector('#publish_on_minute[value="50"]')
    end

    it 'should set the value of each field correctly when given a Date' do
      date_val = @c.render(:datetime_field_with_date_value)

      date_val.should have_selector('#publish_on_day[value="28"]')
      date_val.should have_selector('#publish_on_month[value="2"]')
      date_val.should have_selector('#publish_on_year[value="2009"]')
      date_val.should have_selector('#publish_on_hour[value=""]')
      date_val.should have_selector('#publish_on_minute[value=""]')
    end

    it 'should set the value of each field correctly when given a DateTime' do
      datetime_val = @c.render(:datetime_field_with_datetime_value)

      datetime_val.should have_selector('#publish_on_day[value="28"]')
      datetime_val.should have_selector('#publish_on_month[value="2"]')
      datetime_val.should have_selector('#publish_on_year[value="2009"]')
      datetime_val.should have_selector('#publish_on_hour[value="1"]')
      datetime_val.should have_selector('#publish_on_minute[value="50"]')
    end

    describe 'when disabled=true' do
      before(:each) do
        @disabled = @c.render(:datetime_field_disabled)
      end

      it 'should disable all fields if disabled=true' do
        @disabled.should have_selector('#publish_on_day[disabled="disabled"]')
        @disabled.should have_selector('#publish_on_month[disabled="disabled"]')
        @disabled.should have_selector('#publish_on_year[disabled="disabled"]')
        @disabled.should have_selector('#publish_on_hour[disabled="disabled"]')
        @disabled.should have_selector('#publish_on_minute[disabled="disabled"]')
      end

      it 'should add a disabled class to the datepicker' do
        @disabled.should have_selector('.datepicker.disabled')
      end
    end

    describe 'with label="My label"' do
      before(:each) do
        @label = @c.render(:datetime_field_with_label)
      end

      it 'should add a label with text "My label"' do
        @label.should have_selector('label:contains("My label")')
      end

      it "should set the label's for to be the day field" do
        @label.should have_selector(
          'label[for="publish_on_day"]:contains("My label")')
      end

      it 'should not add labels above each text_field' do
        @label.should_not have_selector(
          'label[for="publish_on_month"]:contains("My label")')
        @label.should_not have_selector(
          'label[for="publish_on_year"]:contains("My label")')
        @label.should_not have_selector(
          'label[for="publish_on_hour"]:contains("My label")')
        @label.should_not have_selector(
          'label[for="publish_on_minute"]:contains("My label")')
      end
    end

  end

  # Bound Datetime Fields ====================================================

  describe 'bound_datetime_field' do

    it 'should add id attributes to each field' do
      rendered = @c.render(:bound_datetime_field)

      rendered.should have_selector(
        'input[id="fake_model_publish_on_day"]')
      rendered.should have_selector(
        'input[id="fake_model_publish_on_month"]')
      rendered.should have_selector(
        'input[id="fake_model_publish_on_year"]')
      rendered.should have_selector(
        'input[id="fake_model_publish_on_hour"]')
      rendered.should have_selector(
        'input[id="fake_model_publish_on_minute"]')
    end

    it 'should add name attributes to each field' do
      rendered = @c.render(:bound_datetime_field)

      rendered.should have_selector(
        'input[name="fake_model[publish_on][day]"]')
      rendered.should have_selector(
        'input[name="fake_model[publish_on][month]"]')
      rendered.should have_selector(
        'input[name="fake_model[publish_on][year]"]')
      rendered.should have_selector(
        'input[name="fake_model[publish_on][hour]"]')
      rendered.should have_selector(
        'input[name="fake_model[publish_on][minute]"]')
    end

    it 'should set no values for any field when the object attribute is nil' do
      no_val = @c.render(:bound_datetime_field)

      no_val.should have_selector('#fake_model_publish_on_day[value=""]')
      no_val.should have_selector('#fake_model_publish_on_month[value=""]')
      no_val.should have_selector('#fake_model_publish_on_year[value=""]')
      no_val.should have_selector('#fake_model_publish_on_hour[value=""]')
      no_val.should have_selector('#fake_model_publish_on_minute[value=""]')
    end

    it 'should set the value of each field using the object attribute' do
      time_val = @c.render(:bound_datetime_field_with_value)

      time_val.should have_selector(
        '#fake_model_publish_on_day[value="28"]')
      time_val.should have_selector(
        '#fake_model_publish_on_month[value="2"]')
      time_val.should have_selector(
        '#fake_model_publish_on_year[value="2009"]')
      time_val.should have_selector(
        '#fake_model_publish_on_hour[value="1"]')
      time_val.should have_selector(
        '#fake_model_publish_on_minute[value="50"]')
    end

    it 'should add an error class to each field if the field has an error' do
      error = @c.render(:bound_datetime_field_with_error)

      error.should have_selector('#fake_model_bad_day.error')
      error.should have_selector('#fake_model_bad_month.error')
      error.should have_selector('#fake_model_bad_year.error')
      error.should have_selector('#fake_model_bad_hour.error')
      error.should have_selector('#fake_model_bad_minute.error')
    end

    it 'should disable all fields if disabled=true' do
      disabled = @c.render(:bound_datetime_field_disabled)

      disabled.should have_selector(
        '#fake_model_publish_on_day[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_month[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_year[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_hour[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_minute[disabled="disabled"]')
    end

    it 'should add a label for the day field if label="My label"' do
      label = @c.render(:bound_datetime_field_with_label)
      label.should have_selector(
        'label[for="fake_model_publish_on_day"]:contains("My label")')
    end

  end

  # Unbound Date Fields ======================================================

  describe 'unbound_date_field' do

    before(:each) do
      @rendered = @c.render(:date_field)
    end

    it 'should have a day field' do
      @rendered.should have_selector('input[id="publish_on_day"]')
      @rendered.should have_selector('input[name="publish_on[day]"]')
    end

    it 'should have a month field' do
      @rendered.should have_selector('input[id="publish_on_month"]')
      @rendered.should have_selector('input[name="publish_on[month]"]')
    end

    it 'should have a year field' do
      @rendered.should have_selector('input[id="publish_on_year"]')
      @rendered.should have_selector('input[name="publish_on[year]"]')
    end

    it 'should not have a hour field' do
      @rendered.should_not have_selector('input[id="publish_on_hour"]')
      @rendered.should_not have_selector('input[name="publish_on[hour]"]')
    end

    it 'should not have a minute field' do
      @rendered.should_not have_selector('input[id="publish_on_minute"]')
      @rendered.should_not have_selector('input[name="publish_on[minute]"]')
    end

    describe 'with label="My label"' do
      before(:each) do
        @label = @c.render(:date_field_with_label)
      end

      it 'should add a label with text "My label"' do
        @label.should have_selector('label:contains("My label")')
      end

      it "should set the label's for to be the day field" do
        @label.should have_selector(
          'label[for="publish_on_day"]:contains("My label")')
      end

      it 'should not add labels above each text_field' do
        @label.should_not have_selector(
          'label[for="publish_on_month"]:contains("My label")')
        @label.should_not have_selector(
          'label[for="publish_on_year"]:contains("My label")')
      end
    end

  end

  # Bound Date Fields ========================================================

  describe 'bound_date_field' do

    it 'should set no values for any field when the object attribute is nil' do
      no_val = @c.render(:bound_date_field)

      no_val.should have_selector('#fake_model_publish_on_day[value=""]')
      no_val.should have_selector('#fake_model_publish_on_month[value=""]')
      no_val.should have_selector('#fake_model_publish_on_year[value=""]')
    end

    it 'should set the value of each field using the object attribute' do
      with_val = @c.render(:bound_date_field_with_value)

      with_val.should have_selector('#fake_model_publish_on_day[value="28"]')
      with_val.should have_selector('#fake_model_publish_on_month[value="2"]')
      with_val.should have_selector('#fake_model_publish_on_year[value="2009"]')
    end

    it 'should add an error class to each field if the field has an error' do
      error = @c.render(:bound_date_field_with_error)

      error.should have_selector('#fake_model_bad_day.error')
      error.should have_selector('#fake_model_bad_month.error')
      error.should have_selector('#fake_model_bad_year.error')
    end

    it 'should disable all fields if disabled=true' do
      disabled = @c.render(:bound_date_field_disabled)

      disabled.should have_selector(
        '#fake_model_publish_on_day[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_month[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_year[disabled="disabled"]')
    end

    it 'should add a label for the day field if label="My label"' do
      label = @c.render(:bound_date_field_with_label)
      label.should have_selector(
        'label[for="fake_model_publish_on_day"]:contains("My label")')
    end

  end

  # Unbound Time Fields ======================================================

  describe 'unbound_time_field' do

    before(:each) do
      @rendered = @c.render(:time_field)
    end

    it 'should not have a day field' do
      @rendered.should_not have_selector('input[id="publish_on_day"]')
      @rendered.should_not have_selector('input[name="publish_on[day]"]')
    end

    it 'should not have a month field' do
      @rendered.should_not have_selector('input[id="publish_on_month"]')
      @rendered.should_not have_selector('input[name="publish_on[month]"]')
    end

    it 'should not have a year field' do
      @rendered.should_not have_selector('input[id="publish_on_year"]')
      @rendered.should_not have_selector('input[name="publish_on[year]"]')
    end

    it 'should have a hour field' do
      @rendered.should have_selector('input[id="publish_on_hour"]')
      @rendered.should have_selector('input[name="publish_on[hour]"]')
    end

    it 'should have a minute field' do
      @rendered.should have_selector('input[id="publish_on_minute"]')
      @rendered.should have_selector('input[name="publish_on[minute]"]')
    end

    describe 'with label="My label"' do
      before(:each) do
        @label = @c.render(:time_field_with_label)
      end

      it 'should add a label with text "My label"' do
        @label.should have_selector('label:contains("My label")')
      end

      it "should set the label's for to be the hour field" do
        @label.should have_selector(
          'label[for="publish_on_hour"]:contains("My label")')
      end

      it 'should not add labels above each text_field' do
        @label.should_not have_selector(
          'label[for="publish_on_minute"]:contains("My label")')
      end
    end

  end

  # Bound Time Fields ========================================================

  describe 'bound_time_field' do

    it 'should set no values for any field when the object attribute is nil' do
      no_val = @c.render(:bound_time_field)

      no_val.should have_selector('#fake_model_publish_on_hour[value=""]')
      no_val.should have_selector('#fake_model_publish_on_minute[value=""]')
    end

    it 'should set the value of each field using the object attribute' do
      with_val = @c.render(:bound_time_field_with_value)

      with_val.should have_selector('#fake_model_publish_on_hour[value="1"]')
      with_val.should have_selector('#fake_model_publish_on_minute[value="50"]')
    end

    it 'should add an error class to each field if the field has an error' do
      error = @c.render(:bound_time_field_with_error)

      error.should have_selector('#fake_model_bad_hour.error')
      error.should have_selector('#fake_model_bad_minute.error')
    end

    it 'should disable all fields if disabled=true' do
      disabled = @c.render(:bound_time_field_disabled)

      disabled.should have_selector(
        '#fake_model_publish_on_minute[disabled="disabled"]')
      disabled.should have_selector(
        '#fake_model_publish_on_hour[disabled="disabled"]')
    end

    it 'should add a label for the hour field if label="My label"' do
      label = @c.render(:bound_time_field_with_label)
      label.should have_selector(
        'label[for="fake_model_publish_on_hour"]:contains("My label")')
    end

  end

  # Labels ===================================================================

  describe 'label' do

    it 'should leave the title intact if there are no special strings' do
      label = @c.render(:label)
      label.should have_selector('label:contains("Label")')
      label.should_not have_selector('span')
    end

    it 'should add a required span around asterisks' do
      label = @c.render(:label_with_requirement)
      label.should have_selector('label:contains("Label")')
      label.should have_selector('span.req:contains("*")')
    end

    it 'should add a note span around parenthesis blocks' do
      note = @c.render(:label_with_note)
      note.should have_selector('label:contains("Label")')
      note.should have_selector('span.note:contains("Note")')

      note = @c.render(:label_with_note_in_parens)
      note.should have_selector('label:contains("Label")')
      note.should have_selector('span.note:contains("(Note)")')
    end

  end

end
