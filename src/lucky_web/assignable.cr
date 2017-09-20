module LuckyWeb::Assignable
  macro needs(*type_declarations)
    {% for declaration in type_declarations %}
      {% ASSIGNS[declaration.var] = declaration.type %}
    {% end %}
  end

  macro included
    SETTINGS = {} of Nil => Nil
    ASSIGNS = {} of Nil => Nil

    macro included
      inherit_page_settings

      macro inherited
        inherit_page_settings
      end
    end
  end

  macro inherit_page_settings
    SETTINGS = {} of Nil => Nil
    ASSIGNS = {} of Nil => Nil

    \{% for k, v in @type.ancestors.first.constant :ASSIGNS %}
      \{% ASSIGNS[k] = v %}
    \{% end %}

    \{% for k, v in @type.ancestors.first.constant :SETTINGS %}
      \{% SETTINGS[k] = v %}
    \{% end %}
  end
end
