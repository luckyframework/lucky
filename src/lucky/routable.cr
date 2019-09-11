# Methods for routing HTTP requests and their parameters to actions.
module Lucky::Routable
  macro fallback
    Lucky::RouteNotFoundHandler.fallback_action = {{ @type.name.id }}
    setup_call_method({{ yield }})
  end

  {% for http_method in [:get, :put, :post, :patch, :trace, :delete] %}
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
      match(:{{ http_method.id }}, \{{ path }}) do
        \{{ yield }}
      end
    end
  {% end %}

  # Define a route with a custom HTTP method.
  #
  # Use this method if you need to match a route with a custom HTTP method (verb).
  # For example:
  #
  # ```
  # class Profile::Show
  #   match :options, "/profile" do
  #     # action code here
  #   end
  # end
  #
  # Will respond to an `HTTP OPTIONS` request.
  macro match(method, path)
    {% unless path.starts_with?("/") %}
      {% path.raise "Path must start with a slash. Example: '/#{path}'" %}
    {% end %}

    {% unless method == method.downcase %}
      {% method.raise "HTTP methods should be lower-case symbols. Use #{method.downcase} instead of #{method}." %}
    {% end %}

    add_route({{method}}, {{path}}, {{ @type.name.id }})

    setup_call_method({{ yield }})
  end

  # :nodoc:
  macro setup_call_method(body)
    def call
      # Ensure clients_desired_format is cached by calling it
      clients_desired_format

      %callback_result = run_before_callbacks

      %response = if %callback_result.is_a?(Lucky::Response)
        %callback_result
      else
        {{ body }}
      end

      %callback_result = run_after_callbacks

      if %callback_result.is_a?(Lucky::Response)
        %callback_result
      else
        %response
      end
    end
  end

  # Define a nested route that responds to the appropriate HTTP request
  # automatically
  #
  # This works similarly to `route` but it will provide multiple parameters.
  # For example:
  #
  # ```
  # class Posts::Comments::Show
  #   nested_route do
  #     render_text "Post: #{post_id}, Comment: #{comment_id}"
  #   end
  # end
  # ```
  #
  # This action responds to the `/posts/:post_id/comments/:comment_id` path.
  macro nested_route
    infer_nested_route

    setup_call_method({{ yield }})
  end

  # Define a route that responds to the appropriate HTTP request automatically
  #
  # ```
  # class Posts::Show
  #   route do
  #     render_text "Post: #{post_id}"
  #   end
  # end
  # ```
  #
  # This action responds to the `/posts/:post_id` path.
  #
  # Each route needs a few pieces of information to be created:
  #
  # * The HTTP method, like `GET`, `POST`, `DELETE`, etc.
  # * The path, such as `/users/:user_id`
  # * The class to route to, like `Users::Show`
  #
  # The `route` method will try to determine these pieces of information based
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
  macro route
    infer_route

    setup_call_method({{ yield }})
  end

  # :nodoc:
  macro infer_nested_route
    infer_route(has_parent: true)
  end

  # :nodoc:
  macro infer_route(has_parent = false)
    {{ run "../run_macros/infer_route", @type.name, has_parent }}
  end

  # :nodoc:
  macro add_route(method, path, action)
    Lucky::Router.add({{ method }}, {{ path }}, {{ @type.name.id }})

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}

    {% for part in path_parts %}
      {% if part.starts_with?(":") %}
        {% part = part.gsub(/:/, "").id %}
        def {{ part }} : String
          params.get(:{{ part }})
        end
      {% end %}
    {% end %}

    def self.path(*args, **named_args) : String
      route(*args, **named_args).path
    end

    def self.url(*args, **named_args) : String
      route(*args, **named_args).url
    end

    def self.url_without_query_params(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}
    )
      path = path_from_parts(
        {% for param in path_params %}
          {{ param.gsub(/:/, "").id }},
        {% end %}
      )
      Lucky::RouteHelper.new({{ method }}, path).url
    end

    def self.route(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}

    {% params_with_defaults = PARAM_DECLARATIONS.select do |decl|
         decl.value || decl.type.is_a?(Union) && decl.type.types.last.id == Nil.id
       end %}
    {% params_without_defaults = PARAM_DECLARATIONS.reject do |decl|
         params_with_defaults.includes? decl
       end %}
    {% for param in params_without_defaults + params_with_defaults %}
      {% is_nilable_type = param.type.is_a?(Union) %}
      {% no_default = !param.value && param.value != false && param.value != nil %}
      {{ param }}{% if is_nilable_type && no_default %} = nil{% end %},
    {% end %}
    anchor : String? = nil
      ) : Lucky::RouteHelper
      path = path_from_parts(
        {% for param in path_params %}
          {{ param.gsub(/:/, "").id }},
        {% end %}
      )
      query_params = {} of String => String
      {% for param in PARAM_DECLARATIONS %}
        {% if param.value == false %}
          {% default_value = false %}
        {% else %}
          {% default_value = param.value || nil %}
        {% end %}
        param_is_default_or_nil = {{ param.var }} == {{ default_value }}
        unless param_is_default_or_nil
          query_params["{{ param.var }}"] = {{ param.var }}.to_s
        end
      {% end %}
      unless query_params.empty?
        path += "?#{HTTP::Params.encode(query_params)}"
      end

      anchor.try do |value|
        path += "#"
        path += URI.encode_www_form(value)
      end

      Lucky::RouteHelper.new {{ method }}, path
    end

    def self.with(*args, **named_args) : Lucky::RouteHelper
      route(*args, **named_args)
    end

    def self.with
      \{% raise "Use `route` instead of `with` if the route doesn't need params" %}
    end

    private def self.path_from_parts(
        {% for param in path_params %}
          {{ param.gsub(/:/, "").id }},
        {% end %}
    )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << URI.encode_www_form({{ part.gsub(/:/, "").id }}.to_param)
          {% else %}
            path << URI.encode_www_form({{ part }})
          {% end %}
        {% end %}
      end

      is_root_path = path == ""
      path = "/" if is_root_path
      path
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

  # Access query and POST parameters
  #
  # When a query parameter or POST data is passed to an action, it is stored in
  # the params object. But accessing the param directly from the params object
  # isn't type safe. Enter `param`. It checks the given param's type and makes
  # it easily available inside the action.
  #
  # ```
  # class Posts::Index < BrowserAction
  #   param page : Int32?
  #
  #   route do
  #     render_text "Posts - Page #{page || 1}"
  #   end
  # end
  # ```
  #
  # To generate a link with a param, use the `with` method:
  # `Posts::Index.with(10).path` which will generate `/posts?page=10`. Visiting
  # that path would render the above action like this:
  #
  # ```text
  # Posts - Page 10
  # ```
  #
  # This works behind the scenes by creating a `page` method in the action to
  # access the parameter.
  #
  # **Note:** Params can also have a default, but then their routes will not
  # include the parameter in the query string. Using the `with(10)` method for a
  # param like this:
  # `param page : Int32 = 1` will only generate `/posts`.
  #
  # These parameters are also typed. The path `/posts?page=ten` will raise a
  # `Lucky::Exceptions::InvalidParam` error because `ten` is a String not an
  # Int32.
  #
  # Additionally, if the param is non-optional it will raise the
  # `Lucky::Exceptions::MissingParam` error if the required param is absent
  # when making a request:
  #
  # ```
  # class UserConfirmations::New
  #   param token : String # this param is required!
  #
  #   route do
  #     # confirm the user with their `token`
  #   end
  # end
  # ```
  #
  # When visiting this page, the path _must_ contain the token parameter:
  # `/user_confirmations?token=abc123`
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
