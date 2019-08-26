module Lucky::InputHelpers
  macro error_message_for_unallowed_field
    {% raise <<-ERROR
      The attribute is not permitted.

      Try this...

        ▸ Allow the attribute to be filled by adding
        'permit_columns {attribute_name}' to your form object.

      Q. Why aren't column attributes permitted by default?
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

  def submit(text : String, **html_options)
    input merge_options(html_options, {"type" => "submit", "value" => text})
  end

  generate_helpful_error_for textarea

  def textarea(field : Avram::PermittedAttribute, **html_options)
    textarea field.param.to_s, merge_options(html_options, {
      "id"   => input_id(field),
      "name" => input_name(field),
    })
  end

  def checkbox(field : Avram::PermittedAttribute(T),
               unchecked_value : String,
               checked_value : String,
               **html_options) forall T
    if field.param == checked_value
      html_options = merge_options(html_options, {"checked" => "true"})
    end
    html_options = merge_options(html_options, {"value" => checked_value})
    generate_input(field, "hidden", {"id" => ""}, {"value" => unchecked_value})
    generate_input(field, "checkbox", html_options)
  end

  def checkbox(field : Avram::PermittedAttribute(Bool?), **html_options)
    unchecked_value = "false"
    if field.value
      html_options = merge_options(html_options, {"checked" => "true"})
    end
    html_options = merge_options(html_options, {"value" => "true"})
    generate_input(field, "hidden", {"id" => ""}, {"value" => unchecked_value})
    generate_input(field, "checkbox", html_options)
  end

  generate_helpful_error_for checkbox

  {% for input_type in ["text", "email", "file", "color", "hidden", "number", "url", "search", "range"] %}
    generate_helpful_error_for {{input_type.id}}_input

    # Returns a {{ input_type.id }} input field.
    #
    # ```
    # {{input_type.id}}_input(attribute)
    # # => <input type="{{input_type.id}}" id="param_key_attribute_name" name="param_key:attribute_name" value="" />
    # ```
    def {{input_type.id}}_input(field : Avram::PermittedAttribute, **html_options)
      generate_input(field, {{input_type}}, html_options)
    end

    # Similar to {{input_type.id}}_input; this allows for Boolean attributes
    # through `attrs`.
    #
    # ```
    # {{input_type.id}}_input(attribute, attrs: [:required])
    # # => <input type="{{input_type.id}}" id="param_key_attribute_name" name="param_key:attribute_name" value="" required />
    # ```
    def {{input_type.id}}_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options)
      generate_input(field, {{input_type}}, html_options, attrs: attrs)
    end
  {% end %}

  generate_helpful_error_for telephone_input

  def telephone_input(field : Avram::PermittedAttribute, **html_options)
    generate_input(field, "tel", html_options)
  end

  def telephone_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options)
    generate_input(field, "tel", html_options, attrs: attrs)
  end

  generate_helpful_error_for password_input

  def password_input(field : Avram::PermittedAttribute, **html_options)
    generate_input(field, "password", html_options, {"value" => ""})
  end

  def password_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options)
    generate_input(field, "password", html_options, {"value" => ""}, attrs)
  end

  generate_helpful_error_for time_input

  def time_input(field : Avram::PermittedAttribute, **html_options)
    value = field.value.try(&.to_s("%H:%M:%S")) || field.param.to_s
    generate_input(field, "time", html_options, {"value" => value})
  end

  def time_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options)
    value = field.value.try(&.to_s("%H:%M:%S")) || field.param.to_s
    generate_input(field, "time", html_options, input_overrides: {"value" => value}, attrs: attrs)
  end

  generate_helpful_error_for date_input

  def date_input(field : Avram::PermittedAttribute, **html_options)
    value = field.value.try(&.to_s("%Y-%m-%d")) || field.param.to_s
    generate_input(field, "date", html_options, {"value" => value})
  end

  def date_input(field : Avram::PermittedAttribute, attrs : Array(Symbol), **html_options)
    value = field.value.try(&.to_s("%Y-%m-%d")) || field.param.to_s
    generate_input(field, "date", html_options, input_overrides: {"value" => value}, attrs: attrs)
  end

  private def generate_input(field,
                             type,
                             html_options,
                             input_overrides = {} of String => String,
                             attrs : Array(Symbol) = [] of Symbol)
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
