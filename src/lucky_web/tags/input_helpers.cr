module LuckyWeb::InputHelpers
  def text_input(field : LuckyRecord::Field, **html_options)
    input_options = {
      "type"  => "text",
      "name"  => input_name(field),
      "value" => field.param.to_s,
    }
    input merge_options(html_options, input_options)
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end
end
