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
    # * [Routing](https://luckyframework.org/guides/http-and-routing/routing-and-params#routing)
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

  # Implement this macro in your action to check the path for a particular style.
  #
  # By default Lucky ships with a `Lucky::EnforceUnderscoredRoute` that is included
  # in your `BrowserAction` and `ApiAction` (as of Lucky 0.28)
  #
  # See the docs for `Lucky::EnforceUnderscoredRoute` to learn how to use it or disable it.
  macro enforce_route_style(path, action)
    # no-op by default
  end

  private NORMALIZED_ROUTES = {} of _ => _

  # :nodoc:
  macro enforce_route_uniqueness(method, original_path)
    # Regex for capturing the param part for normalization
    #
    # So "/users/:user_id" is changed to "/users/:normalized"
    {% normalized_path = original_path.gsub(/(\:\w*)/, ":normalized") %}
    {% normalized_key = "#{method.id} #{normalized_path.id}" %}

    {% if already_used_route = NORMALIZED_ROUTES[normalized_key] %}
      {% raise <<-ERROR
      #{original_path} in '#{@type.name}' collides with the path in '#{already_used_route[:action]}'

      Try this...

        ▸ Change the paths in one of the actions to something unique
        ▸ Run `lucky routes` to verify all of your route paths

      ERROR
      %}
    {% else %}
      {% NORMALIZED_ROUTES[normalized_key] = {
           normalized_path: normalized_path,
           original_path:   original_path,
           method:          method,
           action:          @type.name,
         } %}
    {% end %}
  end

  # :nodoc:
  macro add_route(method, path, action)
    {% path = ROUTE_SETTINGS[:prefix] + path %}

    enforce_route_style({{ path }}, {{ @type.name.id }})
    enforce_route_uniqueness({{method}}, {{ path }})

    Lucky.router.add({{ method }}, {{ path }}, {{ @type.name.id }})
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

    def self.path_without_query_params(
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
      Lucky::RouteHelper.new({{ method }}, path).path
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
      {{ param.gsub(/^\?:/, "").id }} = nil,
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

    def self.with(
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
        {{ param.gsub(/^\?:/, "").id }} = nil,
      {% end %}
      anchor : String? = nil
        ) : Lucky::RouteHelper
      \{% begin %}
      route(
        \{% for arg in @def.args %}
          \{{ arg.name }}: \{{ arg.internal_name }},
        \{% end %}
      )
      \{% end %}
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
  #   get "/posts" do
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
  # class UserConfirmations::New < BrowserAction
  #   param token : String # this param is required!
  #
  #   get "/user_confirmations/new" do
  #     # confirm the user with their `token`
  #   end
  # end
  # ```
  #
  # When visiting this page, the path _must_ contain the token parameter:
  # `/user_confirmations/new?token=abc123`
  macro param(type_declaration)
    {% unless type_declaration.is_a?(TypeDeclaration) %}
      {% raise "'param' expects a type declaration like 'name : String', instead got: '#{type_declaration}'" %}
    {% end %}

    {% PARAM_DECLARATIONS << type_declaration %}
    @@query_param_declarations << "{{ type_declaration.var }} : {{ type_declaration.type }}"

    getter {{ type_declaration.var }} : {{ type_declaration.type }} do
      {% is_nilable_type = type_declaration.type.resolve.nilable? %}
      {% base_type = is_nilable_type ? type_declaration.type.types.first : type_declaration.type %}
      {% is_array = base_type.is_a?(Generic) %}
      {% type = is_array ? base_type.type_vars.first : base_type %}

      {% if is_array %}
      val = params.get_all?(:{{ type_declaration.var.id }})
      {% else %}
      val = params.get?(:{{ type_declaration.var.id }})
      {% end %}

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

      result = Lucky::ParamParser.parse(val, {{ base_type }})

      if result.nil?
        raise Lucky::InvalidParamError.new(
          param_name: "{{ type_declaration.var.id }}",
          param_value: val.to_s,
          param_type: "{{ type }}"
        )
      end

      result
    end
  end
end
