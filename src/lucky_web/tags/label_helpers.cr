module LuckyWeb::LabelHelpers
  def label_for(field : LuckyRecord::AllowedField, **html_options)
    label field.name.to_s.humanize, html_options
  end
end
