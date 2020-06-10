module Lucky::SpecialtyTags
  # Generates an HTML5 doctype tag.
  def html_doctype : Nil
    view << "<!DOCTYPE html>"
  end

  # Generates a link tag for a stylesheet at the path *href*.
  #
  # Additional tag attributes can be passed in keyword arguments via *options*.
  def css_link(href, **options) : Nil
    options = {href: href, rel: "stylesheet", media: "screen"}.merge(options)
    empty_tag "link", **options
  end

  # Generates a script tag for a file at path *src*.
  #
  # Additional tag attributes can be passed in as keyword arguments via
  # *options*.
  def js_link(src, **options) : Nil
    options = {src: src}.merge(options)
    tag "script", **options
  end

  # Generates a meta tag to specify the character encoding as UTF-8.
  #
  # It is highly encouraged to specify the character encoding as early in a
  # page's `<head>` as possible as some browsers only look at the first 1024
  # bytes to determine the encoding.
  def utf8_charset : Nil
    meta charset: "utf-8"
  end

  # Generates a meta tag telling browsers to render the page as wide as the
  # device screen/window and at an initial scale of 1.
  #
  # Optional keyword arguments can be used to override these defaults, as well
  # as specify additional properties. Please refer to [MDN's documentation on
  # the viewport meta tag](https://developer.mozilla.org/en-US/docs/Mozilla/Mobile/Viewport_meta_tag)
  # for usage details.
  def responsive_meta_tag(**options) : Nil
    options = {width: "device-width", initial_scale: "1"}.merge(options)
    meta name: "viewport", content: build_viewport_properties(options)
  end

  # Generates a canonical link tag to specify the "canonical" or "preferred"
  # version of a page.
  def canonical_link(href : String) : Nil
    empty_tag "link", href: href, rel: "canonical"
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
  def raw(string : String) : Nil
    view << string
  end

  # Generates an escaped HTML `&nbsp;` entity for the number of times specified
  # by `how_many`. By default it generates 1 non-breaking space character.
  #
  # ```
  # link "Home", to: Home::Index
  # span do
  #   nbsp
  #   text "|"
  #   nbsp
  # end
  # link "About", to: About::Index
  # ```
  # Would generate `<a href="/">Home</a><span>&nbsp;|&nbsp;</span><a href="/about">About</a>`
  def nbsp(how_many : Int32 = 1) : Nil
    how_many.times { raw("&nbsp;") }
    view
  end

  private def build_viewport_properties(options) : String
    String.build do |attrs|
      options.each_with_index do |key, value, index|
        attrs << ", " if index > 0
        attrs << Wordsmith::Inflector.dasherize(key.to_s) << "="
        attrs << value.to_s
      end
    end
  end
end
