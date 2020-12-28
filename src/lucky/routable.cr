# Methods for routing HTTP requests and their parameters to actions.
module Lucky::Routable
  macro included
    ROUTE_SETTINGS = {prefix: ""}

    macro included
      inherit_route_settings
    end

    macro inherited
      ROUTE_SETTINGS = {prefix: ""}
      inherit_route_settings
    end
  end

  macro inherit_route_settings
    \{% for k, v in @type.ancestors.first.constant :ROUTE_SETTINGS %}
      \{% ROUTE_SETTINGS[k] = v %}
    \{% end %}
  end

  macro fallback
    Lucky::RouteNotFoundHandler.fallback_action = {{ @type.name.id }}
    setup_call_method({{ yield }})
  end

  # Sets the prefix for all routes defined by the match
  # and http method (get, put, post, etc..) macros
  macro route_prefix(prefix)
    {% unless prefix.starts_with?("/") %}
      {% prefix.raise "Prefix must start with a slash. Example: '/#{prefix}'" %}
    {% end %}
    {% ROUTE_SETTINGS[:prefix] = prefix %}
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

    add_route({{method}}, {{ path }}, {{ @type.name.id }})

    setup_call_method({{ yield }})
  end

  # :nodoc:
  macro setup_call_method(body)
    def call
      # Ensure clients_desired_format is cached by calling it
      clients_desired_format

      %pipe_result = run_before_pipes

      %response = if %pipe_result.is_a?(Lucky::Response)
        %pipe_result
      else
        {{ body }}
      end

      %pipe_result = run_after_pipes

      if %pipe_result.is_a?(Lucky::Response)
        %pipe_result
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
  #     plain_text "Post: #{post_id}, Comment: #{comment_id}"
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
  #     plain_text "Post: #{post_id}"
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
    Lucky::Router.add({{ method }}, {{ ROUTE_SETTINGS[:prefix] + path }}, {{ @type.name.id }})

    {% path = ROUTE_SETTINGS[:prefix] + path %}
    {% path_parts = path.split('/').reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(':')) %}
    {% optional_path_params = path_parts.select(&.starts_with?("?:")) %}
    {% glob_param = path_parts.select(&.starts_with?("*")) %}
    {% if glob_param.size > 1 %}
      {% glob_param.raise "Only one glob can be in a path, but found more than one." %}
    {% end %}
    {% glob_param = glob_param.first %}
    {% if glob_param && path_parts.last != glob_param %}
      {% glob_param.raise "Glob param must be defined at the end of the path." %}
    {% end %}

    {% for param in path_params %}
      {% if param.includes?("-") %}
        {% param.raise "Path variables must only use underscores. Use #{param.gsub(/-/, "_")} instead of #{param}." %}
      {% end %}
      {% part = param.gsub(/:/, "").id %}
      def {{ part }} : String
        params.get(:{{ part }})
      end
    {% end %}

    {% for param in optional_path_params %}
      {% if param.includes?("-") %}
        {% param.raise "Optional path variables must only use underscores. Use #{param.gsub(/-/, "_")} instead of #{param}." %}
      {% end %}
      {% part = param.gsub(/^\?:/, "").id %}
      def {{ part }} : String?
        params.get?(:{{ part }})
      end
    {% end %}

    {% if glob_param %}
      {% if glob_param.includes?("-") %}
        {% glob_param.raise "Named globs must only use underscores. Use #{glob_param.gsub(/-/, "_")} instead of #{glob_param}." %}
      {% end %}
      {% part = nil %}
      {% if glob_param.starts_with?("*:") %}
        {% part = glob_param.gsub(/\*:/, "") %}
      {% elsif glob_param == "*" %}
        {% part = "glob" %}
      {% else %}
        {% glob_param.raise "Invalid glob format #{glob_param}." %}
      {% end %}
      def {{ part.id }} : String?
        params.get?({{ part.id.symbolize }})
      end
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
    {% for param in optional_path_params %}
      {{ param.gsub(/^\?:/, "").id }} = nil,
    {% end %}
    )
      path = path_from_parts(
        {% for param in path_params %}
          {{ param.gsub(/:/, "").id }},
        {% end %}
        {% for param in optional_path_params %}
          {{ param.gsub(/^\?:/, "").id }},
        {% end %}
      )
      Lucky::RouteHelper.new({{ method }}, path).url
    end

    {% params_with_defaults = PARAM_DECLARATIONS.select do |decl|
         !decl.value.is_a?(Nop) || decl.type.is_a?(Union) && decl.type.types.last.id == Nil.id
       end %}
    {% params_without_defaults = PARAM_DECLARATIONS.reject do |decl|
         params_with_defaults.includes? decl
       end %}

    def self.route(
    # required path variables
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}

    # required params
    {% for param in params_without_defaults %}
      {{ param }},
    {% end %}

    # params with a default value set are always nilable
    {% for param in params_with_defaults %}
      {{ param.var }} = nil,
    {% end %}

    # optional path variables are nilable
    {% for param in optional_path_params %}
      {{ param.gsub(/^\?:/, "").id }} : String? = nil,
    {% end %}
    anchor : String? = nil
      ) : Lucky::RouteHelper
      path = path_from_parts(
        {% for param in path_params %}
          {{ param.gsub(/:/, "").id }},
        {% end %}
        {% for param in optional_path_params %}
          {{ param.gsub(/^\?:/, "").id }},
        {% end %}
      )
      query_params = {} of String => String
      {% for param in PARAM_DECLARATIONS %}
        # add query param if given and not nil
        query_params["{{ param.var }}"] = {{ param.var }}.to_s unless {{ param.var }}.nil?
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

    def self.route(*_args, **_named_args) : Lucky::RouteHelper
      {% requireds = path_params.map { |param| "#{param.gsub(/:/, "").id}" } %}
      {% params_without_defaults.each { |param| requireds << "#{param.var}" } %}
      {% optionals = optional_path_params.map { |param| "#{param.gsub(/^\?:/, "").id}" } %}
      {% params_with_defaults.each { |param| optionals << "#{param.var}" } %}
      \{% raise <<-ERROR
        Invalid call to {{ @type }}.route

        {% if !requireds.empty? %}
        Required arguments:
        {% for req in requireds %}\n- {{ req.id }}{% end %}
        {% end %}{% if !optionals.empty? %}
        Optional arguments:
        {% for opts in optionals %}\n- {{ opts.id }}{% end %}
        {% end %}
        For more information, refer to https://luckyframework.org/guides/http-and-routing/link-generation.
        ERROR
      %}
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
        {% for param in optional_path_params %}
          {{ param.gsub(/^\?:/, "").id }},
        {% end %}
    )
      path = String.build do |path|
        {% for part in path_parts %}
          {% if part.starts_with?("?:") %}
            if {{ part.gsub(/^\?:/, "").id }}
              path << "/"
              path << URI.encode_www_form({{ part.gsub(/^\?:/, "").id }}.to_param)
            end
          {% elsif part.starts_with?(':') %}
            path << "/"
            path << URI.encode_www_form({{ part.gsub(/:/, "").id }}.to_param)
          {% else %}
            path << "/"
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

    @@query_param_declarations : Array(String) = [] of String
    class_getter query_param_declarations : Array(String)

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
  #     plain_text "Posts - Page #{page || 1}"
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
  # `Lucky::InvalidParamError` error because `ten` is a String not an
  # Int32.
  #
  # Additionally, if the param is non-optional it will raise the
  # `Lucky::MissingParamError` error if the required param is absent
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
    @@query_param_declarations << "{{ type_declaration.var }} : {{ type_declaration.type }}"

    def {{ type_declaration.var }} : {{ type_declaration.type }}
      {% is_nilable_type = type_declaration.type.is_a?(Union) %}
      {% type = is_nilable_type ? type_declaration.type.types.first : type_declaration.type %}

      val = params.get?(:{{ type_declaration.var.id }})

      if val.nil?
        default_or_nil = {{ type_declaration.value.is_a?(Nop) ? nil : type_declaration.value }}
        {% if is_nilable_type %}
          return default_or_nil
        {% else %}
          if default_or_nil.nil?
            raise Lucky::MissingParamError.new("{{ type_declaration.var.id }}")
          else
            return default_or_nil
          end
        {% end %}
      end

      result = {{ type }}::Lucky.parse(val)

      if result.is_a? {{ type }}::Lucky::SuccessfulCast
        result.value
      else
        raise Lucky::InvalidParamError.new(
          param_name: "{{ type_declaration.var.id }}",
          param_value: val.to_s,
          param_type: "{{ type }}"
        )
      end
    end
  end
end
