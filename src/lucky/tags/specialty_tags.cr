module Lucky::SpecialtyTags
  # Generates an HTML5 doctype tag.
  def html_doctype
    view << "<!DOCTYPE html>"
  end

  # Generates a link tag for a stylesheet at the path *href*.
  #
  # Additional tag attributes can be passed in keyword arguments via *options*.
  def css_link(href, **options)
    options = {href: href, rel: "stylesheet", media: "screen"}.merge(options)
    empty_tag "link", **options
  end

  # Generates a script tag for a file at path *src*.
  #
  # Additional tag attributes can be passed in as keyword arguments via
  # *options*.
  def js_link(src, **options)
    options = {src: src}.merge(options)
    tag "script", **options
  end

  # Generates a meta tag to specify the character encoding as UTF-8.
  #
  # It is highly encouraged to specify the character encoding as early in a
  # page's `<head>` as possible as some browsers only look at the first 1024
  # bytes to determine the encoding.
  def utf8_charset
    meta charset: "utf-8"
  end

  # Generates a meta tag telling browsers to render the page as wide as the
  # device screen/window and at an initial scale of 1.
  #
  # Should only be used if the page is intended to be viewed on mobile devices.
  # See the [MDN's documentation on the meta
  # tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta) for
  # details.
  def responsive_meta_tag
    meta name: "viewport", content: "width=device-width, initial-scale=1"
  end

  # Adds *string* directly to the rendered HTML with no escaping.
  #
  # For example,
  # ```
  # raw "<hopefully-something-safe>" # Renders "<hopefully-something-safe>"
  # ```
  #
  # For custom elements, it's recommended to use the `tag` method.
  #
  # NOTE: Should **never** be used to render unescaped user-generated data, as
  # this can leave one vulnerable to [cross-site scripting
  # attacks](https://en.wikipedia.org/wiki/Cross-site_scripting).
  def raw(string : String)
    view << string
  end

  # Generates an escaped HTML `&nbsp;` entity for the number of times specified
  # by `how_many`. By default it generates 1 space character.
  #
  # ```
  # link "Home", to: Home::Index
  # span do
  #   space
  #   text "|"
  #   space
  # end
  # link "About", to: About::Index
  # ```
  # Would generate `<a href="/">Home</a><span>&nbsp;|&nbsp;</span><a href="/about">About</a>`
  def space(how_many : Int32 = 1)
    how_many.times { raw("&nbsp;") }
    view
  end
end
