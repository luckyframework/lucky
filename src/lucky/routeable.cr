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
      )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << {{ part.gsub(/:/, "").id }}
          {% else %}
            path << {{ part }}
          {% end %}
        {% end %}
      end
      is_root_path = path == ""
      path = "/" if is_root_path
      path
    end

    def self.route(
    {% for param in path_params %}
      {{ param.gsub(/:/, "").id }},
    {% end %}
      )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << {{ part.gsub(/:/, "").id }}.to_param
          {% else %}
            path << {{ part }}
          {% end %}
        {% end %}
      end

      is_root_path = path == ""
      path = "/" if is_root_path
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
end
