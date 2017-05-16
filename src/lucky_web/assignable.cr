module LuckyWeb::Assignable
  ASSIGNS = [] of Symbol

  macro assign(*type_declarations)
    {% for declaration in type_declarations %}
      {% ASSIGNS << declaration.var %}
      getter {{declaration}}
    {% end %}
  end

  macro finished
    generate_initializer
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
