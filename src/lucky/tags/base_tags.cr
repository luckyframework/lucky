module Lucky::BaseTags
  include Lucky::CheckTagContent
  TAGS = %i(
    a
    abbr
    address
    area
    article
    aside
    b
    bdi
    bdo
    blockquote
    body
    button
    caption
    cite
    code
    col
    colgroup
    data
    datalist
    del
    details
    dfn
    dialog
    div
    dd
    dl
    dt
    em
    embed
    fieldset
    figcaption
    figure
    footer
    form
    h1
    h2
    h3
    h4
    h5
    h6
    head
    header
    html
    i
    iframe
    ins
    kbd
    label
    legend
    li
    main
    map
    mark
    menuitem
    meter
    nav
    noscript
    object
    ol
    optgroup
    option
    output
    param
    picture
    pre
    progress
    q
    rp
    rt
    ruby
    s
    samp
    script
    section
    slot
    small
    span
    strong
    sub
    summary
    sup
    table
    tbody
    td
    template
    textarea
    tfoot
    th
    thead
    time
    title
    tr
    track
    u
    ul
    video
    wbr
  )
  RENAMED_TAGS     = {"para": "p", "select_tag": "select"}
  EMPTY_TAGS       = %i(img br hr input meta source)
  EMPTY_HTML_ATTRS = {} of String => String

  macro generate_tag_methods(method_name, tag)
    # Generates a `&lt;{{method_name.id}}&gt;&lt;/{{method_name.id}}&gt;` tag.
    #
    # * The *content* argument is either a `String`, or any type that has included `Lucky::AllowedInTags`. This is the content that goes inside of the tag.
    # * The *options* argument is a `Hash(String, String)` of any HTML attribute that has a key/value like `class`, `id`, `type`, etc...
    # * The *attrs* argument is an `Array(Symbol)` for specifying [Boolean Attributes](https://html.spec.whatwg.org/multipage/common-microsyntaxes.html#boolean-attributes) such as `required`, `disabled`, `autofocus`, etc...
    #
    # ```
    # {{method_name.id}}("Sample", {"class" => "cls-1 red"}, [:required]) #=> <{{method_name.id}} class="cls-1 red" required>Sample</{{method_name.id}}>
    # ```
    def {{method_name.id}}(
        content : Lucky::AllowedInTags | String = "",
        options = EMPTY_HTML_ATTRS,
        attrs : Array(Symbol) = [] of Symbol,
        **other_options
      ) : Nil
      boolean_attrs = build_boolean_attrs(attrs)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << boolean_attrs << ">" << HTML.escape(content.to_s) << "</{{tag.id}}>"
    end

    def {{method_name.id}}(content : Lucky::AllowedInTags | String) : Nil
      view << "<{{tag.id}}>" << HTML.escape(content.to_s) << "</{{tag.id}}>"
    end

    def {{method_name.id}}(
        content : Nil,
        options = EMPTY_HTML_ATTRS,
        attrs : Array(Symbol) = [] of Symbol,
        **other_options
      ) : Nil
      \{%
        raise <<-ERROR
          HTML tags content must be a String or Lucky::AllowedInTags object, not nil.

          Try this...

            if value = some_nilable_value
              {{method_name.id}}(value, class: "header")
            end

          ERROR
          %}
    end

    def {{method_name.id}}(
        content : Time,
        options = EMPTY_HTML_ATTRS,
        attrs : Array(Symbol) = [] of Symbol,
        **other_options
      ) : Nil
      \{%
        raise <<-ERROR
          HTML tags content must be a String or Lucky::AllowedInTags object.
          {{method_name.id}} received a Time object which has an ambiguous display format.

          Try this...

            {{method_name.id}}(current_time.to_s("%F"), html_opts)

          ERROR
          %}
    end

    def {{method_name.id}}(options, **other_options) : Nil
      {{ method_name.id }}("", options, **other_options)
    end

    def {{method_name.id}}(options = EMPTY_HTML_ATTRS, **other_options) : Nil
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << ">"
      check_tag_content!(yield)
      view << "</{{tag.id}}>"
    end

    def {{method_name.id}}(attrs : Array(Symbol), options = EMPTY_HTML_ATTRS, **other_options) : Nil
      boolean_attrs = build_boolean_attrs(attrs)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << boolean_attrs << ">"
      check_tag_content!(yield)
      view << "</{{tag.id}}>"
    end

    def {{method_name.id}} : Nil
      view << "<{{tag.id}}>"
      check_tag_content!(yield)
      view << "</{{tag.id}}>"
    end
  end

  {% for tag in TAGS %}
    generate_tag_methods(method_name: {{tag.id}}, tag: {{tag.id}})
  {% end %}

  {% for name, tag in RENAMED_TAGS %}
    generate_tag_methods(method_name: {{name}}, tag: {{tag}})
  {% end %}

  {% for tag in EMPTY_TAGS %}
    # Generates a `&lt;{{tag.id}}&gt;` tag.
    def {{tag.id}} : Nil
      view << %(<{{tag.id}}>)
    end

    def {{tag.id}}(options = EMPTY_HTML_ATTRS, **other_options) : Nil
      {{tag.id}}([] of Symbol, options, **other_options)
    end

    # Generates a `&lt;{{tag.id}}&gt;` tag.
    #
    # * The *attrs* argument is an `Array(Symbol)` for specifying [Boolean Attributes](https://html.spec.whatwg.org/multipage/common-microsyntaxes.html#boolean-attributes) such as `required`, `disabled`, `autofocus`, etc...
    # * The *options* argument is a `Hash(String, String)` of any HTML attribute that has a key/value like `class`, `id`, `type`, etc...
    #
    # ```
    # {{tag.id}}([:required], {"class" => "cls-1"}) #=> <{{tag.id}} class="cls-1" required>
    # ```
    def {{tag.id}}(attrs : Array(Symbol), options = EMPTY_HTML_ATTRS, **other_options) : Nil
      bool_attrs = build_boolean_attrs(attrs)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << %(<{{tag.id}}#{tag_attrs}#{bool_attrs}>)
    end
  {% end %}

  # Outputs *content* and escapes it.
  #
  # ```
  # text("Hello") # => Hello
  # text("<div>") # => &lt;div&gt;
  # ```
  def text(content : String | Lucky::AllowedInTags) : Nil
    view << HTML.escape(content.to_s)
  end

  # Generates a `&lt;style&gt;&lt;/style&gt;` block for adding inline CSS
  #
  # ```
  # style("a { color: red; }") # => <style>a { color: red; }</style>
  # ```
  def style(styles : String) : Nil
    view << "<style>#{styles}</style>"
  end

  private def build_tag_attrs(options)
    return "" if options.empty?

    tag_attrs = String.build do |attrs|
      options.each do |key, value|
        attrs << " " << Wordsmith::Inflector.dasherize(key.to_s) << "=\""
        attrs << HTML.escape(value.to_s)
        attrs << "\""
      end
    end
  end

  private def build_boolean_attrs(options)
    return "" if options.empty?

    String.build do |attrs|
      options.each do |value|
        attrs << " " << Wordsmith::Inflector.dasherize(value.to_s)
      end
    end
  end

  private def merge_options(html_options, tag_attrs)
    options = {} of String => String | Lucky::AllowedInTags
    tag_attrs.each do |key, value|
      options[key.to_s] = value
    end

    html_options.each do |key, value|
      next if key == :boolean_attrs
      options[key.to_s] = value
    end

    options
  end
end
