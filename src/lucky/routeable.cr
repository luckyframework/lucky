# Methods for routing HTTP requests and their parameters to actions.
module Lucky::Routeable
  {% for http_method in [:get, :put, :post, :delete] %}
    # Define a route that responds to a {{ http_method.id.upcase }} request
    #
    # Use these methods if you need a custom path or are using a non-restful
    # route. For example:
    #
    # ```
    # class Profile::ImageUpload
    #   {{ http_method.id }} "/profile/image/:id" do
    #     # action code here
    #   end
    # end
    # ```
    #
    # will respond to an `HTTP {{ http_method.id.upcase }}` request.
    #
    # **See also** our guides for more information and examples:
    # * [Routing](https://luckyframework.org/guides/actions-and-routing/#routing)
    macro {{ http_method.id }}(path)
      add_route :{{ http_method.id }}, \{{ path }}, \{{ @type.name.id }}

      setup_call_method(\{{ yield }})
    end
  {% end %}

  # :nodoc:
  macro setup_call_method(body)
    def call
      callback_result = run_before_callbacks

      response = if callback_result.is_a?(Lucky::Response)
        callback_result
      else
        {{ body }}
      end

      callback_result = run_after_callbacks

      if callback_result.is_a?(Lucky::Response)
        callback_result
      else
        response
      end
    end
  end

  # Define a nested route that responds to the appropriate HTTP request
  # automatically
  #
  # This works similarly to `action` but it will provide multiple parameters.
  # For example:
  #
  # ```
  # class Posts::Comments::Show
  #   nested_action do
  #     render_text "Post: #{post_id}, Comment: #{id}"
  #   end
  # end
  # ```
  #
  # This action responds to the `/posts/:post_id/comments/:id` path.
  #
  # **Note:** The `singular` option will likely be removed soon. Try `get`,
  # `post`, `put`, and `delete` with a custom path instead.
  macro nested_action(singular = false)
    infer_nested_route(singular: {{ singular }})

    setup_call_method({{ yield }})
  end

  # Define a route that responds to the appropriate HTTP request automatically
  #
  # ```
  # class Posts::Show
  #   action do
  #     render_text "Post: #{id}"
  #   end
  # end
  # ```
  #
  # This action responds to the `/posts/:id` path.
  #
  # Each route needs a few pieces of information to be created:
  #
  # * The HTTP method, like `GET`, `POST`, `DELETE`, etc.
  # * The path, such as `/users/:id`
  # * The class to route to, like `Users::Show`
  #
  # The `action` method will try to determine these pieces of information based
  # the class name. After it knows the class, Lucky will transform the full
  # class name to figure out the path, i.e. removing the `::` separators and
  # adding underscores. The method is found via the last part of the class name:
  #
  # * `Index` -> `GET`
  # * `Show` -> `GET`
  # * `New` -> `GET`
  # * `Create` -> `POST`
  # * `Edit` -> `GET`
  # * `Update` -> `PUT`
  # * `Delete` -> `DELETE`
  #
  # If you are using a non-restful action name you should use the `get`, `put`,
  # `post`, or `delete` methods. Otherwise you will see an error like this:
  #
  # ```text
  # Could not infer route for User::ImageUploads
  # ```
  #
  # **See also** our guides for more information and examples:
  # * [Automatically Generate RESTful Routes](https://luckyframework.org/guides/actions-and-routing/#automatically-generate-restful-routes)
  # * [Examples of automatically generated routes](https://luckyframework.org/guides/actions-and-routing/#examples-of-automatically-generated-routes)
  macro action(singular = false)
    infer_route(singular: {{ singular }})

    setup_call_method({{ yield }})
  end

  # :nodoc:
  macro infer_nested_route(singular = false)
    infer_route(has_parent: true, singular: singular)
  end

  # :nodoc:
  macro infer_route(has_parent = false, singular = false)
    {{ run "../run_macros/infer_route", @type.name, has_parent, singular }}
  end

  # :nodoc:
  macro add_route(method, path, action)
    Lucky::Router.add({{ method }}, {{ path }}, {{ @type.name.id }})

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}

    {% for part in path_parts %}
      {% if part.starts_with?(":") %}
        {% part = part.gsub(/:/, "").id %}
        def {{ part }}
          params.get(:{{ part }})
        end
      {% end %}
    {% end %}

    def self.path(*args, **named_args)
      route(*args, **named_args).path
    end

    def self.url(*args, **named_args)
      route(*args, **named_args).url
    end

    def self.route(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}
    {% for param in PARAM_DECLARATIONS %}
      {{ param }},
    {% end %}
    anchor : String? = nil
      )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << URI.escape({{ part.gsub(/:/, "").id }}.to_param)
          {% else %}
            path << URI.escape({{ part }})
          {% end %}
        {% end %}
      end

      is_root_path = path == ""
      path = "/" if is_root_path

      query_params = {} of String => String
      {% for param in PARAM_DECLARATIONS %}
        param_is_default_or_nil = {{ param.var }} == {{ param.value || nil }}
        unless param_is_default_or_nil
          query_params["{{ param.var }}"] = {{ param.var }}.to_s
        end
      {% end %}

      unless query_params.empty?
        path += "?#{HTTP::Params.encode(query_params)}"
      end

      anchor.try do |value|
        path += "#"
        path += URI.escape(value)
      end

      Lucky::RouteHelper.new {{ method }}, path
    end

    def self.with(*args, **named_args)
      route(*args, **named_args)
    end

    def self.with
      \{% raise "Use `route` instead of `with` if the action doesn't need params" %}
    end
  end

  macro included
    PARAM_DECLARATIONS = [] of Crystal::Macros::TypeDeclaration

    macro inherited
      inherit_param_declarations
    end
  end

  # :nodoc:
  macro inherit_param_declarations
    PARAM_DECLARATIONS = [] of Crystal::Macros::TypeDeclaration

    \{% for param_declaration in @type.ancestors.first.constant :PARAM_DECLARATIONS %}
      \{% PARAM_DECLARATIONS << param_declaration %}
    \{% end %}
  end

  # Access a query parameter
  #
  # This will allow any action to accept and access query parameters. By
  # default query parameters are ignored, but adding a `param` will make them
  # available:
  # ```
  # class Posts::Index < BrowserAction
  #   param page : Int32 = 1
  #
  #   action do
  #     render_text "Posts - Page #{page}"
  #   end
  # end
  # ```
  #
  # Visiting `/posts?page=10` would render the following:
  #
  # ```text
  # Posts - Page 10
  # ```
  #
  # Additionally, these parameters are typed. The path `/posts?page=ten` will
  # raise a `Lucky::Exceptions::InvalidParam` error because `ten` is a string
  # not an Int32.
  macro param(type_declaration)
    {% PARAM_DECLARATIONS << type_declaration %}

    def {{ type_declaration.var }} : {{ type_declaration.type }}
      {% is_nilable_type = type_declaration.type.is_a?(Union) %}
      {% type = is_nilable_type ? type_declaration.type.types.first : type_declaration.type %}

      val = params.get?(:{{ type_declaration.var.id }})

      if val.nil?
        default_or_nil = {{ type_declaration.value || nil }}
        {% if is_nilable_type %}
          return default_or_nil
        {% else %}
          return default_or_nil ||
            raise Lucky::Exceptions::MissingParam.new("{{ type_declaration.var.id }}")
        {% end %}
      end

      result = {{ type }}::Lucky.parse(val)

      if result.is_a? {{ type }}::Lucky::SuccessfulCast
        result.value
      else
        raise Lucky::Exceptions::InvalidParam.new(
          param_name: "{{ type_declaration.var.id }}",
          param_value: val.to_s,
          param_type: "{{ type }}"
        )
      end
    end
  end
end
