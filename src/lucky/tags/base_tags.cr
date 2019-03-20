module Lucky::BaseTags
  include Lucky::CheckTagContent
  TAGS             = %i(a address article aside b bdi body button code details dialog div dd dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i iframe label li main mark menuitem meter nav ol option option pre progress rp rt ruby s script section small span strong summary table tbody td textarea th thead time title tr u ul video wbr)
  RENAMED_TAGS     = {"para": "p", "select_tag": "select"}
  EMPTY_TAGS       = %i(img br hr input meta source)
  EMPTY_HTML_ATTRS = {} of String => String

  macro generate_tag_methods(method_name, tag)
    def {{method_name.id}}(
        content : Lucky::AllowedInTags | String = "",
        options = EMPTY_HTML_ATTRS,
        attrs : Array(Symbol) = [] of Symbol,
        **other_options
      )
      merged_options = merge_options(other_options, options)
      {{method_name.id}}(attrs, merged_options) do
        text content
      end
    end

    def {{method_name.id}}(content : String | Lucky::AllowedInTags)
      {{method_name.id}}(EMPTY_HTML_ATTRS) do
        text content
      end
    end

    def {{method_name.id}}(&block)
      {{method_name.id}}(EMPTY_HTML_ATTRS) do
        yield
      end
    end

    def {{method_name.id}}(options = EMPTY_HTML_ATTRS, **other_options, &block)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << "<{{tag.id}}" << tag_attrs << ">"
      check_tag_content!(yield)
      view << "</{{tag.id}}>"
    end

    def {{method_name.id}}(attrs : Array(Symbol), options = EMPTY_HTML_ATTRS, **other_options, &block)
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
    def {{tag.id}}
      view << %(<{{tag.id}}> )
    end

    def {{tag.id}}(options = EMPTY_HTML_ATTRS, **other_options)
      {{tag.id}}([] of Symbol, options, **other_options)
    end

    def {{tag.id}}(attrs : Array(Symbol), options = EMPTY_HTML_ATTRS, **other_options)
      bool_attrs = build_boolean_attrs(attrs)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      view << %(<{{tag.id}}#{tag_attrs}#{bool_attrs}>)
    end
  {% end %}

  def text(content : String | Lucky::AllowedInTags)
    view << HTML.escape(content.to_s)
  end

  def style(styles : String)
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
