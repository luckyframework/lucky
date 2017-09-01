module LuckyWeb::InputHelpers
  def text_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "text", html_options)
  end

  def email_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "email", html_options)
  end

  def color_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "color", html_options)
  end

  def hidden_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "hidden", html_options)
  end

  def number_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "number", html_options)
  end

  def telephone_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "telephone", html_options)
  end

  def url_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "url", html_options)
  end

  def search_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "search", html_options)
  end

  def password_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "password", html_options, {"value" => ""})
  end

  def range_input(field : LuckyRecord::AllowedField, **html_options)
    generate_input(field, "range", html_options)
  end

  private def generate_input(field, type, html_options, input_overrides = {} of String => String)
    input_options = {
      "type"  => type,
      "name"  => input_name(field),
      "value" => field.param.to_s,
    }.merge(input_overrides)
    input merge_options(html_options, input_options)
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end
end
