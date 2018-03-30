module Lucky::Exposeable
  macro included
    EXPOSURES = [] of Symbol
    UNEXPOSED = [] of Symbol

    macro inherited
      EXPOSURES = [] of Symbol
      UNEXPOSED = [] of Symbol

      inherit_exposures
    end
  end

  macro inherit_exposures
    \{% for v in @type.ancestors.first.constant :EXPOSURES %}
      \{% EXPOSURES << v %}
    \{% end %}
    \{% for v in @type.ancestors.first.constant :UNEXPOSED %}
      \{% UNEXPOSED << v %}
    \{% end %}
  end

  macro expose(method_name)
    {% EXPOSURES << method_name.id %}
  end

  macro unexpose(*method_names)
    {% for method_name in method_names %}
      {% if EXPOSURES.includes?(method_name.id) %}
        {% UNEXPOSED << method_name.id %}
      {% else %}
        {% method_name.raise <<-ERROR
        Can't unexpose '#{method_name}' because it was not previously exposed. Check the exposure name or use 'unexpose_if_exposed #{method_name}' if the exposure may or may not exist
        ERROR %}
      {% end %}
    {% end %}
  end

  macro unexpose_if_exposed(*method_names)
    {% for method_name in method_names %}
      {% UNEXPOSED << method_name.id %}
    {% end %}
  end
end
