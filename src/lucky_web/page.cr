require "./tags/**"

module LuckyWeb::Page
  include LuckyWeb::BaseTags
  include LuckyWeb::LinkHelpers
  include LuckyWeb::FormHelpers
  include LuckyWeb::LabelHelpers
  include LuckyWeb::Assignable

  macro included
    # If included directly
    SETTINGS = {} of Nil => Nil
    ASSIGNS = {} of Nil => Nil

    macro inherited
      # If used as a base class, reset the settings and assign when it's inherited
      SETTINGS = {} of Nil => Nil
      ASSIGNS = {} of Nil => Nil
    end
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
