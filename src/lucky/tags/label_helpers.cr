module Lucky::LabelHelpers
  def label_for(field : LuckyRecord::FillableField, **html_options)
    label_for(
      field,
      LuckyInflector::Inflector.humanize(field.name.to_s),
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
end
