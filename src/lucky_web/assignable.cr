module LuckyWeb::Assignable
  macro needs(*type_declarations)
    {% for declaration in type_declarations %}
      {% ASSIGNS[declaration.var] = declaration.type %}
    {% end %}
  end

  macro generate_initializer
    def initialize(
      {% for var, type in ASSIGNS %}
        @{{ var }} : {{ type }},
      {% end %}
      )
    end
  end
end
