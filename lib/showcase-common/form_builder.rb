module Showcase
  module Common
    ##
    # Adds some extra form helpers to the merb-helper defaults.
    #
    # Includes:
    #   * date_field for entering a date.
    #   * time_field for entering a time.
    #   * datetime_field for entering a date and time.
    #   * label_field - tweaks the default to create note blocks and asterisks.
    #
    module Form
      class Builder < Merb::Helpers::Form::Builder::ResourcefulFormWithErrors

        class_inheritable_accessor :datetime_options
        @datetime_options = [
          [:day,    { :maxlength => 2, :size => 3, :desc => 'DD'   }],
          [:month,  { :maxlength => 2, :size => 3, :desc => 'MM'   }],
          [:year,   { :maxlength => 4, :size => 5, :desc => 'YYYY' }],
          [:hour,   { :maxlength => 2, :size => 3, :desc => 'HH'   }],
          [:minute, { :maxlength => 2, :size => 3, :desc => 'MM'   }]
        ]

        ##
        # Creates a field for entering a date.
        # [DD] [MM] [YYYY]
        #
        def bound_date_field(method, attrs = {})
          update_bound_controls(method, attrs, 'date')
          attrs[:value]   = @obj.send(method)
          attrs[:name]  ||= control_name(method)
          unbound_date_field(attrs)
        end

        def unbound_date_field(attrs)
          datetime_label = create_datetime_label(attrs)
          field_opts = create_datetime_options(attrs)

          %(#{ datetime_label }
            #{ generic_datetime_field(:day, field_opts[:day]) }
            #{ generic_datetime_field(:month, field_opts[:month]) }
            #{ generic_datetime_field(:year, field_opts[:year]) }
            #{ date_picker(attrs) })
        end

        ##
        # Creates a field for entering both a time.
        # [HH]:[MM]
        #
        def bound_time_field(method, attrs = {})
          update_bound_controls(method, attrs, 'time')
          attrs[:value]   = @obj.send(method)
          attrs[:name]  ||= control_name(method)
          unbound_time_field(attrs)
        end

        def unbound_time_field(attrs)
          datetime_label = create_datetime_label(attrs, 'hour')
          field_opts = create_datetime_options(attrs)

          %(#{ datetime_label }
            #{ generic_datetime_field(:hour, field_opts[:hour]) }
            <span class="field timesep">:</span>
            #{ generic_datetime_field(:minute, field_opts[:minute]) }
            #{ date_picker(attrs) })
        end

        ##
        # Creates a field for entering both a date and time.
        # [DD] [MM] [YYYY] at [HH]:[MM]
        #
        def bound_datetime_field(method, attrs = {})
          update_bound_controls(method, attrs, 'datetime')
          attrs[:value]   = @obj.send(method)
          attrs[:name]  ||= control_name(method)
          unbound_datetime_field(attrs)
        end

        def unbound_datetime_field(attrs)
          datetime_label = create_datetime_label(attrs)
          field_opts = create_datetime_options(attrs)

          %(#{ datetime_label }
            #{ generic_datetime_field(:day, field_opts[:day]) }
            #{ generic_datetime_field(:month, field_opts[:month]) }
            #{ generic_datetime_field(:year, field_opts[:year]) }
            <span class="field at">at</span>
            #{ generic_datetime_field(:hour, field_opts[:hour]) }
            <span class="field timesep">:</span>
            #{ generic_datetime_field(:minute, field_opts[:minute]) }
            #{ date_picker(attrs) })
        end

        ##
        # A simple wrapper around the built-in label helper. If the label
        # content ends with an asterisk, it will be wrapped in a span such that
        # it appears in red. Similarly, if the note ends with text in
        # parenthesis, the text within will be wrapped in a .note span.
        #
        # @example [Required field]
        #   label('Field *')
        #   # => <label>Field <span class="req">*</span></label>
        #
        # @example [Note]
        #   label('Field (Note)')
        #   # => <label>Field <span class="note">Note</span></label>
        #
        # @example [Note in parenthesis]
        #   label('Field ((Note))')
        #   # => <label>Field <span class="note">(Note)</span></label>
        #
        def label(contents, attrs = {})
          if contents
            contents.sub!(/\*/, '<span class="req">*</span>')
            contents.sub!(/\((.*)\)/, '<span class="note">\1</span>')
          end

          super
        end

        #######
        private
        #######

        ##
        # Creates a date/time text field.
        #
        def generic_datetime_field(name, attrs)
          description = attrs.delete(:desc)

          <<-HTML
            <span class="field #{name}">
              #{unbound_text_field(attrs)}
              <label class="description" for="#{attrs[:id]}">
                #{description}
              </label>
            </span>
          HTML
        end

        ##
        # Merges options given to the date field helpers and returns a hash with
        # options for each individual form field.
        #
        def create_datetime_options(attrs, method = nil)
          values = if (time = attrs[:value])
            case time
            when Time, DateTime
              { :day    => time.day,
                :month  => time.month,
                :year   => time.year,
                :hour   => time.hour,
                :minute => time.min }
            when Date
              { :day    => time.day,
                :month  => time.month,
                :year   => time.year }
            end
          end

          datetime_options.reduce({}) do |h, (suffix, defaults)|
            h[suffix] = defaults.merge(attrs).merge(
              :id    => '%s_%s'  % [attrs[:id] || attrs[:name], suffix],
              :name  => '%s[%s]' % [attrs[:name] || attrs[:id], suffix],
              :value => values && values[suffix]
            ) ; h
          end
        end

        ##
        # Creates a label for the datetime fields, if a :label key is present.
        #
        # This removes the label key from the attrs hash so that an individual
        # label doesn't get added above each individual field.
        #
        def create_datetime_label(attrs, field = 'day')
          if attrs[:label]
            label(attrs.delete(:label),
              :for => '%s_%s' % [attrs[:id] || attrs[:name], field])
          end
        end

        ##
        # Creates HTML to show a datepicker trigger.
        #
        def date_picker(attrs)
          disabled = attrs[:disabled] ? ' disabled' : ''

          <<-HTML
            <span class="field datepicker#{disabled}">
              <a href="#TODO" title="Open the calendar to choose a date">
                Choose a date&hellip;
              </a>
            </span>
          HTML
        end
      end # Builder

      ##
      # Global helpers for creating date, time and datetime fields.
      #
      module Helper
        %w(date_field time_field datetime_field).each do |kind|
          self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{kind}(*args)
              if bound?(*args)
                current_form_context.bound_#{kind}(*args)
              else
                current_form_context.unbound_#{kind}(*args)
              end
            end
          RUBY
        end
      end # Helper
    end # Form
  end # Common
end # Showcase
