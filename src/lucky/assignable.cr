module Lucky::Assignable
  # Declare what a page needs in order to be initialized.
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
      {% if declaration.var.stringify.ends_with?("?") %}
        {% raise "Using '?' in a 'needs' var name is no longer supported. Now Lucky generates a method ending in '?' if the type is 'Bool'." %}
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
        def {{ declaration.var }}?
          @{{ declaration.var }}
        end
      {% else %}
        def {{ declaration.var }}
          @{{ declaration.var }}
        end
      {% end %}

      {% ASSIGNS << declaration %}
    {% end %}
  end

  # :nodoc:
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

  # :nodoc:
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
