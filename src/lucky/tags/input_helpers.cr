module Lucky::InputHelpers
  def submit(text : String, **html_options)
    input merge_options(html_options, {"type" => "submit", "value" => text})
  end

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

  def text_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "text", html_options)
  end

  def email_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "email", html_options)
  end

  def file_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "file", html_options)
  end

  def color_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "color", html_options)
  end

  def hidden_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "hidden", html_options)
  end

  def number_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "number", html_options)
  end

  def telephone_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "telephone", html_options)
  end

  def url_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "url", html_options)
  end

  def search_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "search", html_options)
  end

  def password_input(field : LuckyRecord::FillableField, **html_options)
    generate_input(field, "password", html_options, {"value" => ""})
  end

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
