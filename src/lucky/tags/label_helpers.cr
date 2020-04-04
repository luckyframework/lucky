module Lucky::LabelHelpers
  def label_for(field : Avram::PermittedAttribute, text : String? = nil, **html_options) : Nil
    label(
      text || guess_label_name(field),
      merge_options(html_options, {"for" => input_id(field)})
    )
  end

  def label_for(field : Avram::PermittedAttribute, **html_options) : Nil
    label(merge_options(html_options, {"for" => input_id(field)})) do
      yield
    end
  end

  def label_for(field, **options) : Nil
    Lucky::InputHelpers.error_message_for_unallowed_field
  end

  def label_for(field, **options) : Nil
    Lucky::InputHelpers.error_message_for_unallowed_field
    yield
  end

  private def guess_label_name(field)
    Wordsmith::Inflector.humanize(field.name.to_s)
  end
end
