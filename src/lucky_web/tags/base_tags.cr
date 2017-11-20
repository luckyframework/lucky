module LuckyWeb::BaseTags
  TAGS             = %i(a b body div em small fieldset h1 h2 h3 h4 h5 h6 head html i label li ol option s script span strong table tbody td textarea thead th title tr u ul form footer header article aside bdi details dialog figcaption figure main mark menuitem meter nav progress rp rt ruby section summary time wbr option)
  RENAMED_TAGS     = {"para": "p", "select_tag": "select"}
  EMPTY_TAGS       = %i(img br input meta)
  EMPTY_HTML_ATTRS = {} of String => String

  @view = IO::Memory.new

  macro generate_tag_methods(method_name, tag)
    def {{method_name.id}}(content : String? = "", options = EMPTY_HTML_ATTRS, **other_options)
      merged_options = merge_options(other_options, options)
      {{method_name.id}}(merged_options) do
        text content
      end
    end

    def {{method_name.id}}(content : String | LuckyWeb::AllowedInTags)
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
      @view << "<{{tag.id}}" << tag_attrs << ">"
      yield
      @view << "</{{tag.id}}>"
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
      @view << %(<{{tag.id}}/> )
    end

    def {{tag.id}}(options = EMPTY_HTML_ATTRS, **other_options)
      merged_options = merge_options(other_options, options)
      tag_attrs = build_tag_attrs(merged_options)
      @view << %(<{{tag.id}}#{tag_attrs}/>)
    end
  {% end %}

  def text(content : String | LuckyWeb::AllowedInTags)
    @view << HTML.escape(content.to_s)
  end

  private def build_tag_attrs(options)
    tag_attrs = String.build do |attrs|
      options.each do |key, value|
        attrs << " " << LuckyInflector::Inflector.dasherize(key.to_s) << "=\""
        attrs << HTML.escape(value)
        attrs << "\""
      end
    end
  end

  private def merge_options(html_options, tag_attrs)
    options = {} of String => String
    tag_attrs.each do |key, value|
      options[key.to_s] = value
    end

    html_options.each do |key, value|
      options[key.to_s] = value
    end

    options
  end
end
