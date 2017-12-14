module Lucky::LabelHelpers
  def label_for(field : LuckyRecord::AllowedField, **html_options)
    label_for(
      field,
      LuckyInflector::Inflector.humanize(field.name.to_s),
      **html_options
    )
  end

  def label_for(field : LuckyRecord::AllowedField, text : String, **html_options)
    label(
      text,
      merge_options(html_options, {"for" => input_id(field)})
    )
  end
end
