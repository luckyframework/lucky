module LuckyWeb::InputHelpers
  def text_input(field : LuckyRecord::Field, **html_options)
    generate_input(field, "text", html_options)
  end

  def email_input(field : LuckyRecord::Field, **html_options)
    generate_input(field, "email", html_options)
  end

  def color_input(field : LuckyRecord::Field, **html_options)
    generate_input(field, "color", html_options)
  end

  private def generate_input(field, type, html_options)
    input_options = {
      "type"  => type,
      "name"  => input_name(field),
      "value" => field.param.to_s,
    }
    input merge_options(html_options, input_options)
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end
end
