abstract class LuckyWeb::HTMLView
  abstract def render

  def initialize
    @io = IO::Memory.new
  end

  TAGS             = %i(p header h1 h2 h3 h4 h5 h6 section div footer small span)
  EMPTY_TAGS       = %i(img br)
  EMPTY_HTML_ATTRS = {} of String => String

  {% for tag in TAGS %}
    def {{tag.id}}(content, options)
      {{tag.id}}(options) do
        text content
      end
    end

    def {{tag.id}}(content, **options)
      {{tag.id}}(options) do
        text content
      end
    end

    def {{tag.id}}(content : String)
      {{tag.id}}(EMPTY_HTML_ATTRS) do
        text content
      end
    end

    def {{tag.id}}(&block)
      {{tag.id}}(EMPTY_HTML_ATTRS) do
        yield
      end
    end

    def {{tag.id}}(options, &block)
      tag_attrs = build_tag_attrs(options)
      @io << %(<{{tag.id}}#{tag_attrs}>)
      yield
      @io << %(</{{tag.id}}>)
    end

    def {{tag.id}}(**options, &block)
      tag_attrs = build_tag_attrs(options)
      @io << %(<{{tag.id}}#{tag_attrs}>)
      yield
      @io << %(</{{tag.id}}>)
    end
  {% end %}

  {% for tag in EMPTY_TAGS %}
    def {{tag.id}}
      @io << %(<{{tag.id}}/>)
    end

    def {{tag.id}}(options)
      tag_attrs = build_tag_attrs(options)
      @io << %(<{{tag.id}}#{tag_attrs}/>)
    end

    def {{tag.id}}(**options)
      tag_attrs = build_tag_attrs(options)
      @io << %(<{{tag.id}}#{tag_attrs}/>)
    end
  {% end %}

  def text(content : String)
    @io << content
  end

  private def build_tag_attrs(options)
    tag_attrs = String.build do |attrs|
      options.each do |key, value|
        attrs << %( #{key}="#{value}")
      end
    end
  end

  private def build_tag_attrs(**options)
    tag_attrs = String.build do |attrs|
      options.each do |key, value|
        attrs << %( #{key}="#{value}")
      end
    end
  end
end
