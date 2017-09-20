module LuckyWeb::Exposeable
  macro included
    EXPOSURES = [] of Symbol

    macro inherited
      EXPOSURES = [] of Symbol

      inherit_exposures
    end
  end

  macro inherit_exposures
    \{% for v in @type.ancestors.first.constant :EXPOSURES %}
      \{% EXPOSURES << v %}
    \{% end %}
  end

  macro expose(method_name)
    {% EXPOSURES << method_name.id %}
  end
end
