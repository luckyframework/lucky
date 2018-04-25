module Lucky::InputHelpers
  # class LuckyRecord::FillableField
  #   @name = :name
  # end

  # # Would also allow you to set some default html_options
  # # It *should* also append CSS class names (not override) -- I think
  # # See how simple_form does it for feedback
  # def text_input(**html_options)
  #   input_proc do |fillable_field|
  #     text_input(fillable_field, **html_options)
  #   end
  # end

  # def input_proc(&block : LuckyRecord::FillableField -> Nil)
  #   block
  # end

  # def text_input(field : LuckyRecord::FillableField, **html_options)
  #   p field
  #   p html_options
  # end

  # text_input(autofocus: "true").call(LuckyRecord::FillableField.new)

  macro error_message_for_unallowed_field
    {% raise <<-ERROR
      The field is not fillable.

      Try this...

        ▸ Allow the field to be filled by adding 'fillable {field_name}' to your form object.

      Q. Why aren't fields fillable by default?
      A. Malicious users could submit any field they want. For example: you
         might have an 'admin' flag on a User. If all fields were fillable,
         a malicious user could set the 'admin' flag to 'true' on any form.

      ERROR %}
  end

  macro generate_helpful_error_for(input_method_name)
    def {{ input_method_name.id }}(field, **options)
      error_message_for_unallowed_field
    end
  end

  def submit(text : String, **html_options)
    input merge_options(html_options, {"type" => "submit", "value" => text})
  end

  generate_helpful_error_for textarea

  def textarea(field : LuckyRecord::FillableField, **html_options)
    textarea field.param.to_s, merge_options(html_options, {
      "id"   => input_id(field),
      "name" => input_name(field),
    })
  end

  def checkbox(field : LuckyRecord::FillableField,
               unchecked_value : String? = nil,
               **html_options)
    hidden_value = unchecked_value || "0"
    generate_input(field, "hidden", {"id" => ""}, {"value" => hidden_value})
    generate_input(field, "checkbox", html_options)
  end

  generate_helpful_error_for checkbox

  def text_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "text", html_options)
  end

  generate_helpful_error_for email_input

  def email_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "email", html_options)
  end

  generate_helpful_error_for file_input

  def file_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "file", html_options)
  end

  generate_helpful_error_for color_input

  def color_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "color", html_options)
  end

  generate_helpful_error_for hidden_input

  def hidden_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "hidden", html_options)
  end

  generate_helpful_error_for number_input

  def number_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "number", html_options)
  end

  generate_helpful_error_for telephone_input

  def telephone_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "telephone", html_options)
  end

  generate_helpful_error_for url_input

  def url_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "url", html_options)
  end

  generate_helpful_error_for search_input

  def search_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "search", html_options)
  end

  generate_helpful_error_for password_input

  def password_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "password", html_options, {"value" => ""})
  end

  generate_helpful_error_for range_input

  def range_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "range", html_options)
  end

  private def generate_input(field,
                             type,
                             html_options,
                             input_overrides = {} of String => String)
    input_options = {
      "type"  => type,
      "id"    => input_id(field),
      "name"  => input_name(field),
      "value" => field.param.to_s,
    }.merge(input_overrides)
    input merge_options(html_options, input_options)
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end

  private def input_id(field)
    "#{field.form_name}_#{field.name}"
  end
end
