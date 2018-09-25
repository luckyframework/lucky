module Lucky::CustomTags
  EMPTY_HTML_ATTRS = {} of String => String

  def tag(
    name : String,
    content : Lucky::AllowedInTags | String? = "",
    options = EMPTY_HTML_ATTRS,
    **other_options
  )
    merged_options = merge_options(other_options, options)
    tag(name, merged_options) do
      text content
    end
  end

  def tag(name : String, content : String | Lucky::AllowedInTags)
    tag(EMPTY_HTML_ATTRS) do
      text content
    end
  end

  def tag(name : String, &block)
    tag(EMPTY_HTML_ATTRS) do
      yield
    end
  end

  def tag(name : String, options = EMPTY_HTML_ATTRS, **other_options, &block)
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)
    @view << "<#{name}" << tag_attrs << ">"
    yield
    @view << "</#{name}>"
  end

  # Outputs a custom tag with no tag closing.
  # `empty_tag("br")` => `<br>`
  def empty_tag(name : String, options = EMPTY_HTML_ATTRS, **other_options)
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)
    @view << "<#{name}" << tag_attrs << ">"
  end
end
