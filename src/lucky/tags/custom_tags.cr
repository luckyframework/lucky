module Lucky::CustomTags
  include Lucky::CheckTagContent
  EMPTY_HTML_ATTRS = {} of String => String

  def tag(
    tag_name : String,
    content : Lucky::AllowedInTags | String? = "",
    options = EMPTY_HTML_ATTRS,
    attrs : Array(Symbol) = [] of Symbol,
    **other_options
  ) : Nil
    merged_options = merge_options(other_options, options)

    tag(tag_name, attrs, merged_options) do
      text content
    end
  end

  def tag(
    tag_name : String,
    options = EMPTY_HTML_ATTRS,
    **other_options
  ) : Nil
    tag(tag_name, "", options, **other_options)
  end

  def tag(tag_name : String, attrs : Array(Symbol) = [] of Symbol, options = EMPTY_HTML_ATTRS, **other_options) : Nil
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)
    boolean_attrs = build_boolean_attrs(attrs)
    view << "<#{tag_name}" << tag_attrs << boolean_attrs << ">"
    check_tag_content!(yield)
    view << "</#{tag_name}>"
  end

  # Outputs a custom tag with no tag closing.
  # `empty_tag("br")` => `<br>`
  def empty_tag(tag_name : String, options = EMPTY_HTML_ATTRS, **other_options) : Nil
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)
    view << "<#{tag_name}" << tag_attrs << ">"
  end
end
