module Lucky::LabelHelpers
  def label_for(field : Avram::PermittedAttribute, text : String, **html_options)
    label(
      text,
      merge_options(html_options, {"for" => input_id(field)})
    )
  end

  def label_for(field : Avram::PermittedAttribute, **html_options)
    label(merge_options(html_options, {"for" => input_id(field)})) do
      yield
    end
  end

  def label_for(field : Avram::PermittedAttribute, **options)
    {% raise <<-ERROR
      'label_for' no longer guesses the label text. Please provide the text for this label.

      Try this...

        ▸ label_for operation.my_attribute, "This is the label text"


      ERROR
    %}
  end

  def label_for(field, **options)
    Lucky::InputHelpers.error_message_for_unallowed_field
  end

  def label_for(field, **options)
    Lucky::InputHelpers.error_message_for_unallowed_field
    yield
  end
end
