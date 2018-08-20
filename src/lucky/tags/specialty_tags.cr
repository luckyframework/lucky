module Lucky::SpecialtyTags
  def html_doctype
    @view << "<!DOCTYPE html>"
  end

  def css_link(href, **options)
    options = {href: href, rel: "stylesheet", media: "screen"}.merge(options)
    tag "link", **options
  end

  def js_link(src, **options)
    options = {src: src}.merge(options)
    tag "script", **options
  end

  def utf8_charset
    meta charset: "utf-8"
  end

  def responsive_meta_tag
    meta name: "viewport", content: "width=device-width, initial-scale=1"
  end

  def raw(string : String)
    @view << string
  end
end
