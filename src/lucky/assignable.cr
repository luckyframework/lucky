module Lucky::Assignable
  # Declare what a class needs in order to be initialized.
  #
  # This will declare an instance variable and getter automatically. It will
  # also add arguments to an `initialize` method at the end of compilation.
  #
  # ### Examples
  #
  # ```
  # class Users::IndexPage < MainLayout
  #   # This page needs a `User` or it will fail to compile
  #   # You can access it with `@user` or the getter method `user`
  #   needs user : User
  #
  #   # This page can take an optional `ProductQuery`. This means you can
  #   # Leave `products` off when rendering from an Action.
  #   needs products : ProductQuery?
  #
  #   # When using a `Bool` Lucky will generate a method ending with `?`
  #   # So in this case you can call `should_show_sidebar?` in the page.
  #   needs should_show_sidebar : Bool = true
  # end
  # ```
  macro needs(*type_declarations)
    {% for declaration in type_declarations %}
      {% unless declaration.is_a?(TypeDeclaration) %}
        {% raise "'needs' expects a type declaration like 'name : String', instead got: '#{declaration}'" %}
      {% end %}

      # Ensure that the needs variable name has not been previously defined.
      {% previous_declaration = ASSIGNS.find { |d| d.var == declaration.var } %}
      {% if previous_declaration %}
        {% raise <<-ERROR
          \n
          Duplicate needs definition: '#{declaration}' defined in #{declaration.filename}:#{declaration.line_number}:#{declaration.column_number}
          This needs is already defined as '#{previous_declaration}' in #{previous_declaration.filename}:#{previous_declaration.line_number}:#{previous_declaration.column_number}
          ERROR
        %}
      {% end %}

      {% if declaration.type.stringify == "Bool" %}
        getter? {{ declaration.var }}
      {% else %}
        getter {{ declaration.var }}
      {% end %}

      {% ASSIGNS << declaration %}
    {% end %}
  end

  # :nodoc:
  macro inherit_assigns
    macro included
      inherit_assigns
    end

    macro inherited
      inherit_assigns
    end

    {% if !@type.has_constant?(:ASSIGNS) %}
      ASSIGNS = [] of Nil
      {% verbatim do %}
        {% if @type.ancestors.first %}
          {% for declaration in @type.ancestors.first.constant(:ASSIGNS) %}
            {% ASSIGNS << declaration %}
          {% end %}
        {% end %}
      {% end %}
    {% end %}
  end

  macro setup_initializer_hook
    macro finished
      generate_needy_initializer
    end

    macro included
      setup_initializer_hook
    end

    macro inherited
      setup_initializer_hook
    end
  end

  macro generate_needy_initializer
    {% if !@type.abstract? %}
      {% sorted_assigns = ASSIGNS.sort_by { |dec|
           has_explicit_value =
             dec.type.is_a?(Metaclass) ||
               dec.type.types.map(&.id).includes?(Nil.id) ||
               !dec.value.is_a?(Nop)
           has_explicit_value ? 1 : 0
         } %}
      def initialize(
        {% for declaration in sorted_assigns %}
          {% var = declaration.var %}
          {% type = declaration.type %}
          {% value = declaration.value %}
          {% value = nil if type.stringify.ends_with?("Nil") && !value %}
          @{{ var.id }} : {{ type }}{% if !value.is_a?(Nop) %} = {{ value }}{% end %},
        {% end %}
        **unused_exposures
        )
      end
    {% end %}
  end

  setup_initializer_hook
  inherit_assigns
end
