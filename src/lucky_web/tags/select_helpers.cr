module LuckyWeb::SelectHelpers
  alias SelectOption = (String | Int32 | Int64)

  def select_input(field : LuckyRecord::AllowedField, **html_options)
    select_tag merge_options(html_options, {"name" => input_name(field)}) do
      yield
    end
  end

  def options_for_select(field : LuckyRecord::AllowedField, select_options : Array(String, SelectOption), **html_options)
    select_options.each do |select_name, select_value|
       is_selected = if select_value.to_s == field.value.to_s
         "true"
       else
          "false"
       end
      option select_name, merge_options(html_options, {"value" => select_value.to_s, "selected" => is_selected})
    end
  end

  private def input_name(field)
    "#{field.form_name}:#{field.name}"
  end
end
