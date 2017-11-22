module Lucky::SpecialtyTags
  def html_doctype
    @view << "<!DOCTYPE html>"
  end

  def css_link(href, rel = "stylesheet", media = "screen")
    tag_attrs = build_tag_attrs({href: href, rel: rel, media: media})
    @view << "<link" << tag_attrs << ">"
  end

  def js_link(src, **options)
    options = merge_options(options, {"src" => src})
    tag_attrs = build_tag_attrs(options)
    @view << "<script" << tag_attrs << "></script>"
  end

  def utf8_charset
    raw %(<meta charset="utf-8">)
  end

  def raw(string : String)
    @view << string
  end
end
