require "./tags/**"

module LuckyWeb::Page
  include LuckyWeb::BaseTags
  include LuckyWeb::LinkHelpers
  include LuckyWeb::FormHelpers
  include LuckyWeb::LabelHelpers
  include LuckyWeb::InputHelpers
  include LuckyWeb::SpecialtyTags
  include LuckyWeb::Assignable
  include LuckyWeb::AssetHelpers

  macro layout(layout_class)
    {% SETTINGS[:has_layout] = true %}
    def render
      {{layout_class}}.new(self, @view).render.to_s
    end
  end

  macro generate_initializer
    def initialize(
      {% for var, type in ASSIGNS %}
        @{{ var }} : {{ type }},
      {% end %}
      )
    end
  end

  macro render
    {% if SETTINGS[:has_layout] %}
      {% render_method_name = :render_inner %}
    {% else %}
      {% render_method_name = :render %}
    {% end %}
    def {{ render_method_name.id }}
      {{ yield }}
      @view
    end

    generate_initializer
  end

  macro p(_arg, **args)
    {% raise <<-ERROR
      `p` is not available on Lucky pages. This is because it's not clear whether you want to print something out or use a `p` HTML tag.
      
      Instead try:
        * The `para` method if you want to use an HTML paragraph.
        * The `pp` method to pretty print information for debugging.
      ERROR %}
  end
end
