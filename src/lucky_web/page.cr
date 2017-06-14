require "./tags/**"

module LuckyWeb::Page
  include LuckyWeb::LinkHelpers
  include LuckyWeb::BaseTags
  include LuckyWeb::Assignable

  macro included
    SETTINGS = {} of Nil => Nil
  end

  macro layout(layout_class)
    {% SETTINGS[:has_layout] = true %}
    def render
      {{layout_class}}.new(self, @view).render.to_s
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
end
