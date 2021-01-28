module Lucky::BaseTags
  include Lucky::CheckTagContent
  TAGS             = %i(a abbr address article aside b bdi blockquote body button cite code details dialog div dd dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i iframe label li main mark menuitem meter nav ol option pre progress rp rt ruby s script section small span strong summary table tbody td template textarea tfoot th thead time title tr u ul video wbr)
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
      merged_options = merge_options(other_options, options)
      {{method_name.id}}(attrs, merged_options) do
        text content
      end
    end

    def {{method_name.id}}(options = EMPTY_HTML_ATTRS, **other_options) : Nil
      {{ method_name.id }}("", options, **other_options)
    end

    def {{method_name.id}}(content : String | Lucky::AllowedInTags) : Nil
      {{method_name.id}}(EMPTY_HTML_ATTRS) do
        text content
      end
    end

    def {{method_name.id}}(&block) : Nil
      {{method_name.id}}(EMPTY_HTML_ATTRS) do
        yield
      end
    end

    def {{method_name.id}}(options = EMPTY_HTML_ATTRS, **other_options, &block) : Nil
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << ">"
      check_tag_content!(yield)
      view << "</{{tag.id}}>"
    end

    def {{method_name.id}}(attrs : Array(Symbol), options = EMPTY_HTML_ATTRS, **other_options, &block) : Nil
      boolean_attrs = build_boolean_attrs(attrs)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << boolean_attrs << ">"
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
    tag_attrs = String.build do |attrs|
      options.each do |key, value|
        attrs << " " << Wordsmith::Inflector.dasherize(key.to_s) << "=\""
        attrs << HTML.escape(value.to_s)
        attrs << "\""
      end
    end
  end

  private def build_boolean_attrs(options)
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
