module Lucky::InputHelpers
  EMPTY_BOOLEAN_ATTRIBUTES = [] of Symbol

  macro error_message_for_unallowed_field
    {% raise <<-ERROR
      The database attribute for the operation is not permitted and cannot be used in a form.

      Try allowing the attribute to be filled...

          class MySaveOperation # SaveUser, SaveTask, etc.
            permit_columns {attribute_name}
          end

      View more about 'permit_columns'

        https://luckyframework.org/guides/database/validating-saving#perma-permitting-columns

      Q. Why aren't database attributes permitted by default?
      A. Malicious users could submit any value they want. For example: you
         might have an 'admin' flag on a User. If all attributes were
         permitted, a malicious user could set the 'admin' flag to 'true'
         on any form.

      ERROR
    %}
  end

  macro generate_helpful_error_for(input_method_name)
    def {{ input_method_name.id }}(field : Avram::Attribute, **options)
      Lucky::InputHelpers.error_message_for_unallowed_field
    end
  end

  def submit(text : String, **html_options) : Nil
    input merge_options(html_options, {"type" => "submit", "value" => text})
  end

  generate_helpful_error_for textarea

  # Returns a textarea field.
  #
  # ```
  # textarea(attribute)
  # # => <textarea id="param_key_attribute_name" name="param_key:attribute_name"></textarea>
  # ```
  def textarea(field : Avram::PermittedAttribute, **html_options) : Nil
    textarea field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  # Similar to textarea; this allows for Boolean attributes
  # through `attrs`.
  #
  # ```
  # textarea(attribute, attrs: [:required])
  # # => <textarea id="param_key_attribute_name" name="param_key:attribute_name" required></textarea>
  # ```
  def textarea(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    textarea field.param.to_s, merge_options(html_options, {
      "id"   => input_id(field),
      "name" => input_name(field),
    }), attrs: attrs
  end

  def checkbox(field : Avram::PermittedAttribute(T),
               unchecked_value : String,
               checked_value : String,
               **html_options) : Nil forall T
    if field.param == checked_value
      html_options = merge_options(html_options, {"checked" => "true"})
    end
    html_options = merge_options(html_options, {"value" => checked_value})
    generate_input(field, "hidden", {"id" => ""}, {"value" => unchecked_value})
    generate_input(field, "checkbox", html_options)
  end

  def checkbox(field : Avram::PermittedAttribute(Bool), **html_options) : Nil
    checkbox field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def checkbox(field : Avram::PermittedAttribute(Bool), attrs : Array(Symbol), **html_options) : Nil
    unchecked_value = "false"
    if field.value
      html_options = merge_options(html_options, {"checked" => "true"})
    end
    html_options = merge_options(html_options, {"value" => "true"})
    generate_input(field, "hidden", {"id" => ""}, {"value" => unchecked_value})
    generate_input(field, "checkbox", html_options, attrs: attrs)
  end

  generate_helpful_error_for checkbox

  # Returns a radio input field.
  #
  # ```
  # radio(attribute, "checked_value")
  # # => <input type="radio" id="param_key_attribute_name_checked_value" name="param_key:attribute_name" value="checked_value" checked="true">
  # ```
  def radio(field : Avram::PermittedAttribute(String),
            checked_value : String,
            **html_options) : Nil
    radio field, checked_value, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  # Similar to radio; this allows for Boolean attributes through `attrs`.
  #
  # ```
  # radio(attribute, "checked_value", attrs: [:required])
  # # => <input type="radio" id="param_key_attribute_name_checked_value" name="param_key:attribute_name" value="checked_value" checked="true" required />
  # ```
  def radio(field : Avram::PermittedAttribute(String),
            checked_value : String,
            attrs : Array(Symbol),
            **html_options) : Nil
    if field.value == checked_value
      html_options = merge_options(html_options, {"checked" => "true"})
    end
    overrides = {"id" => input_id(field) + "_#{checked_value}", "value" => checked_value}
    html_options = merge_options(html_options, overrides)
    generate_input(field, "radio", html_options, attrs: attrs)
  end

  generate_helpful_error_for radio

  {% for input_type in ["text", "email", "file", "color", "hidden", "number", "url", "search", "range"] %}
    generate_helpful_error_for {{input_type.id}}_input

    # Returns a {{ input_type.id }} input field.
    #
    # ```
    # {{input_type.id}}_input(attribute)
    # # => <input type="{{input_type.id}}" id="param_key_attribute_name" name="param_key:attribute_name" value="" />
    # ```
    def {{input_type.id}}_input(field : Avram::PermittedAttribute, **html_options) : Nil
      {{input_type.id}}_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
    end

    # Similar to {{input_type.id}}_input; this allows for Boolean attributes
    # through `attrs`.
    #
    # ```
    # {{input_type.id}}_input(attribute, attrs: [:required])
    # # => <input type="{{input_type.id}}" id="param_key_attribute_name" name="param_key:attribute_name" value="" required />
    # ```
    def {{input_type.id}}_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
      generate_input(field, {{input_type}}, html_options, attrs: attrs)
    end
  {% end %}

  generate_helpful_error_for telephone_input

  def telephone_input(field : Avram::PermittedAttribute, **html_options) : Nil
    telephone_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def telephone_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    generate_input(field, "tel", html_options, attrs: attrs)
  end

  generate_helpful_error_for password_input

  def password_input(field : Avram::PermittedAttribute, **html_options) : Nil
    password_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def password_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    generate_input(field, "password", html_options, {"value" => ""}, attrs)
  end

  generate_helpful_error_for time_input

  def time_input(field : Avram::PermittedAttribute, **html_options) : Nil
    time_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def time_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    value = field.value.try(&.to_s("%H:%M:%S")) || field.param.to_s
    generate_input(field, "time", html_options, input_overrides: {"value" => value}, attrs: attrs)
  end

  generate_helpful_error_for date_input

  def date_input(field : Avram::PermittedAttribute, **html_options) : Nil
    date_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def date_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    value = field.value.try(&.to_s("%Y-%m-%d")) || field.param.to_s
    generate_input(field, "date", html_options, input_overrides: {"value" => value}, attrs: attrs)
  end

  generate_helpful_error_for datetime_input

  def datetime_input(field : Avram::PermittedAttribute, **html_options) : Nil
    datetime_input field, EMPTY_BOOLEAN_ATTRIBUTES, **html_options
  end

  def datetime_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options) : Nil
    value = field.value.try(&.to_s("%Y-%m-%dT%H:%M:%S")) || field.param.to_s
    generate_input(field, "datetime-local", html_options, input_overrides: {"value" => value}, attrs: attrs)
  end

  private def generate_input(field,
                             type,
                             html_options,
                             input_overrides = {} of String => String,
                             attrs : Array(Symbol) = [] of Symbol) : Nil
    input_options = {
      "type"  => type,
      "id"    => input_id(field),
      "name"  => input_name(field),
      "value" => field.param.to_s,
    }.merge(input_overrides)
    input attrs, merge_options(html_options, input_options)
  end

  private def input_name(field)
    "#{field.param_key}:#{field.name}"
  end

  private def input_id(field)
    "#{field.param_key}_#{field.name}"
  end
end
