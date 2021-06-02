module Lucky::SelectHelpers
  def select_input(field : Avram::PermittedAttribute, **html_options) : Nil
    select_tag merge_options(html_options, {"name" => input_name(field)}) do
      yield
    end
  end

  def multi_select_input(field : Avram::PermittedAttribute, **html_options) : Nil
    select_tag [:multiple], merge_options(html_options, {"name" => input_name(field, array: true)}) do
      yield
    end
  end

  def options_for_select(field : Avram::PermittedAttribute(T), select_options : Array(Tuple(String, T?)), **html_options) : Nil forall T
    select_options.each do |option_name, option_value|
      attributes = {"value" => option_value.to_s}

      is_selected = option_value.to_s == field.param.to_s
      attributes["selected"] = "true" if is_selected

      option(option_name, merge_options(html_options, attributes))
    end
  end

  def options_for_multi_select(field : Avram::PermittedAttribute(Array(T)), select_options : Array(Tuple(String, T)), **html_options) : Nil forall T
    select_options.each do |option_name, option_value|
      attributes = {"value" => option_value.to_s}
      bool_attrs = [] of Symbol

      if value = field.value
        is_selected = value.includes?(option_value.to_s)
        bool_attrs << :selected if is_selected
      end

      option(option_name, attrs: bool_attrs, options: merge_options(html_options, attributes))
    end
  end

  # Renders an <option> HTML tag with no value
  # The text is set to `label`.
  def select_prompt(label : String) : Nil
    option(label, value: "")
  end

  private def input_name(field, *, array : Bool = false)
    String.build do |name|
      name << "#{field.param_key}:#{field.name}"
      name << "[]" if array
    end
  end
end
