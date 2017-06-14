module LuckyWeb::Assignable
  macro included
    macro included
      ASSIGNS = [] of Symbol
    end
  end

  macro assign(*type_declarations)
    {% for declaration in type_declarations %}
      {% ASSIGNS << declaration.var %}
      getter {{declaration}}
    {% end %}
  end

  macro generate_initializer
    def initialize(
      {% for var in ASSIGNS %}
        @{{var}},
      {% end %}
      )
    end
  end
end
