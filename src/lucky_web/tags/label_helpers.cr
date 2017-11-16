module LuckyWeb::LabelHelpers
  def label_for(field : LuckyRecord::AllowedField, **html_options)
    label(
      field.name.to_s.humanize,
      merge_options(html_options, {"for" => input_id(field)})
    )
  end
end
