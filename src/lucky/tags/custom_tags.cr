module Lucky::CustomTags
  EMPTY_HTML_ATTRS = {} of String => String

  def tag(
    name : String,
    content : Lucky::AllowedInTags | String? = "",
    options = EMPTY_HTML_ATTRS,
    **other_options
  )
    bool_attrs, other_options = extract_boolean_attrs(other_options)
    bool_attrs = build_boolean_attrs(bool_attrs.as(Array))
    merged_options = merge_options(other_options, options)

    tag(name, merged_options, boolean_attrs: bool_attrs) do
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
    bool_attrs = other_options[:boolean_attrs]?.to_s
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)
    @view << "<#{name}" << tag_attrs << bool_attrs << ">"
    yield
    @view << "</#{name}>"
  end

  # `options` is a NamedTuple that may or may not contain `attrs: []`
  # returns Tuple(Array(Symbol), Hash(Symbol, String))
  private def extract_boolean_attrs(options)
    hash = options.to_h
    bool_attrs = hash[:attrs]? || [] of Symbol
    other_options = hash.reject { |key, _| key == :attrs }
    return {bool_attrs, other_options}
  end
end
