module LuckyWeb::Exposeable
  macro included
    EXPOSURES = [] of Symbol

    macro inherited
      EXPOSURES = [] of Symbol
    end
  end

  macro expose(method_name)
    {% EXPOSURES << method_name.id %}
  end
end
