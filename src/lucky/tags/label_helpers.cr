module Lucky::LabelHelpers
  def label_for(field : LuckyRecord::FillableField, **html_options)
    label_for(
      field,
      Wordsmith::Inflector.humanize(field.name.to_s),
      **html_options
    )
  end

  def label_for(field : LuckyRecord::FillableField, text : String, **html_options)
    label(
      text,
      merge_options(html_options, {"for" => input_id(field)})
    )
  end

  def label_for(field : LuckyRecord::FillableField, **html_options)
    label(merge_options(html_options, {"for" => input_id(field)})) do
      yield
    end
  end

  def label_for(field, **options)
    Lucky::InputHelpers.error_message_for_unallowed_field
  end

  def label_for(field, **options)
    Lucky::InputHelpers.error_message_for_unallowed_field
    yield
  end
end
