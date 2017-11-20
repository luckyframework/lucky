module LuckyWeb::LabelHelpers
  def label_for(field : LuckyRecord::AllowedField, **html_options)
    label(
      LuckyInflector::Inflector.humanize(field.name.to_s),
      merge_options(html_options, {"for" => input_id(field)})
    )
  end
end
