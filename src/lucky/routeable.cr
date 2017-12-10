module Lucky::Routeable
  {% for http_method in [:get, :put, :post, :delete] %}
    macro {{ http_method.id }}(path)
      add_route :{{ http_method.id }}, \{{ path }}, \{{ @type.name.id }}

      setup_call_method(\{{ yield }})
    end
  {% end %}

  macro setup_call_method(body)
    def call : Lucky::Response
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

  macro nested_action(singular = false)
    infer_nested_route(singular: {{ singular }})

    setup_call_method({{ yield }})
  end

  macro action(singular = false)
    infer_route(singular: {{ singular }})

    setup_call_method({{ yield }})
  end

  macro infer_nested_route(singular = false)
    infer_route(has_parent: true, singular: singular)
  end

  macro infer_route(has_parent = false, singular = false)
    {{ run "../run_macros/infer_route", @type.name, has_parent, singular }}
  end

  macro add_route(method, path, action)
    Lucky::Router.add({{ method }}, {{ path }}, {{ @type.name.id }})

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}

    {% for part in path_parts %}
      {% if part.starts_with?(":") %}
        {% part = part.gsub(/:/, "").id %}
        def {{ part }}
          params.get!(:{{ part }})
        end
      {% end %}
    {% end %}

    def self.path(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}
    {% for param in PARAM_DECLARATIONS %}
      {{ param }},
    {% end %}
      )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << URI.escape({{ part.gsub(/:/, "").id }})
          {% else %}
            path << URI.escape({{ part }})
          {% end %}
        {% end %}
      end
      is_root_path = path == ""
      path = "/" if is_root_path

      query_params = {} of String => String
      {% for param in PARAM_DECLARATIONS %}
        unless {{ param.var }} == {{ param.value || nil }}
          query_params["{{ param.var }}"] = {{ param.var }}.to_s
        end
      {% end %}

      unless query_params.empty?
        path += "?#{HTTP::Params.encode(query_params)}"
      end

      path
    end

    def self.route(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}
    {% for param in PARAM_DECLARATIONS %}
      {{ param }},
    {% end %}
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
        unless {{ param.var }} == {{ param.value || nil }}
          query_params["{{ param.var }}"] = {{ param.var }}.to_s
        end
      {% end %}

      unless query_params.empty?
        path += "?#{HTTP::Params.encode(query_params)}"
      end

      Lucky::RouteHelper.new {{ method }}, path
    end

    def self.with(**args)
      route(**args)
    end

    def self.with(*args)
      route(*args)
    end

    def self.with
      \{% raise "Use `route` instead of `with` if the action doesn't need params" %}
    end
  end

  macro included
    PARAM_DECLARATIONS = [] of Crystal::Macros::TypeDeclaration

    macro inherited
      PARAM_DECLARATIONS = [] of Crystal::Macros::TypeDeclaration
    end
  end

  macro param(type_declaration)
    {% PARAM_DECLARATIONS << type_declaration %}

    def {{ type_declaration.var }} : {{ type_declaration.type }}
      val = params.get(:{{ type_declaration.var.id }})
      if val.nil?
        {{ type_declaration.value || nil }}
      else
        {% if type_declaration.type.class_name == "Union" %}
          result = {{ type_declaration.type.types.first }}::Lucky.parse(val)
          if result.is_a? {{ type_declaration.type.types.first }}::Lucky::SuccessfulCast
            result.value
          else
            nil
          end
        {% else %}
          result = {{ type_declaration.type }}::Lucky.parse(val)
          if result.is_a? {{ type_declaration.type }}::Lucky::SuccessfulCast
            result.value
          else
            raise "Non-optional param \"{{ type_declaration.var.id }}\" couldn't be parsed to a \"{{ type_declaration.type }}\""
          end
      {% end %}
      end
    end
  end
end
