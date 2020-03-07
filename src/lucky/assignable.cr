# :nodoc:
module Lucky::Assignable
  macro needs(*type_declarations)
    {% for declaration in type_declarations %}
      {% unless declaration.is_a?(TypeDeclaration) %}
        {% raise "'needs' expects a type declaration like 'name : String', instead got: '#{declaration}'" %}
      {% end %}
      {% if declaration.var.stringify.ends_with?("?") %}
        {% raise "Using '?' in a 'needs' var name is no longer supported. Now Lucky generates a method ending in '?' if the type is 'Bool'." %}
      {% end %}
      {% ASSIGNS << declaration %}
    {% end %}
  end

  macro included
    SETTINGS = {} of Nil => Nil
    ASSIGNS = [] of Nil

    macro included
      inherit_page_settings

      macro inherited
        inherit_page_settings
      end
    end
  end

  macro inherit_page_settings
    SETTINGS = {} of Nil => Nil
    ASSIGNS = [] of Nil

    \{% for declaration in @type.ancestors.first.constant :ASSIGNS %}
      \{% ASSIGNS << declaration %}
    \{% end %}

    \{% for k, v in @type.ancestors.first.constant :SETTINGS %}
      \{% SETTINGS[k] = v %}
    \{% end %}
  end
end
