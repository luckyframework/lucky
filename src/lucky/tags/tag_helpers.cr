module Lucky::TagHelpers
  include Lucky::BaseTags

  def content_tag(name : String | Symbol, options = EMPTY_HTML_ATTRS, **other_options, &block)
    merged_options = merge_options(other_options, options)
    tag_attrs = build_tag_attrs(merged_options)

    buffer = IO::Memory.new
    buffer << "<#{name.to_s}" << tag_attrs << ">"
    buffer << capture(&block)
    buffer << "</#{name.to_s}>"
    buffer.to_s
  end

  def content_tag(name : String | Symbol, inner : String | Nil, options = EMPTY_HTML_ATTRS, **other_options, escape = false)
    block = -> { raw(inner.to_s) }
    content_tag(name, options, **other_options, &block)
  end
end
