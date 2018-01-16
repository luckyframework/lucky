module Lucky::SelectHelpers
  alias SelectOption = (String | Int32 | Int64)

  def select_input(field : LuckyRecord::AllowedField, **html_options)
    select_tag merge_options(html_options, {"name" => input_name(field)}) do
      yield
    end
  end

  def options_for_select(field : LuckyRecord::AllowedField, select_options : Array(Tuple(String, SelectOption)), **html_options)
    select_options.each do |option_name, option_value|
      attributes = {"value" => option_value.to_s}

      is_selected = option_value.to_s == field.param.to_s
      attributes["selected"] = "true" if is_selected

      option(option_name, merge_options(html_options, attributes))
    end
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end
end
