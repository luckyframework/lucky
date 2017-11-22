module LuckyWeb::Routeable
  macro included
    OPTIONAL_PARAMS = [] of Symbol

    macro inherited
      OPTIONAL_PARAMS = [] of Symbol

      inherit_optional_params
    end
  end

  macro inherit_optional_params
    \{% for v in @type.ancestors.first.constant :OPTIONAL_PARAMS %}
      \{% OPTIONAL_PARAMS << v %}
    \{% end %}
  end

  {% for http_method in [:get, :put, :post, :delete] %}
    macro {{ http_method.id }}(path)
      add_route :{{ http_method.id }}, \{{ path }}, \{{ @type.name.id }}

      def call : LuckyWeb::Response
        callback_result = run_before_callbacks

        response = if callback_result.is_a?(LuckyWeb::Response)
          callback_result
        else
          \{{ yield }}
        end

        callback_result = run_after_callbacks

        if callback_result.is_a?(LuckyWeb::Response)
          callback_result
        else
          response
        end
      end
    end
  {% end %}

  macro nested_action(singular = false)
    infer_nested_route(singular: {{ singular }})

    def call : LuckyWeb::Response
      {{ yield }}
    end
  end

  macro action(singular = false)
    infer_route(singular: {{ singular }})

    def call : LuckyWeb::Response
      {{ yield }}
    end
  end

  macro infer_nested_route(singular = false)
    infer_route(has_parent: true, singular: singular)
  end

  macro infer_route(has_parent = false, singular = false)
    {{ run "../run_macros/infer_route", @type.name, has_parent, singular }}
  end

  macro add_route(method, path, action)
    LuckyWeb::Router.add({{ method }}, {{ path }}, {{ @type.name.id }})

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

    {% for param in OPTIONAL_PARAMS %}
      {{ param.id }} : String? = nil,
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

    {% for param in OPTIONAL_PARAMS %}
      {{ param.id }} : String? = nil,
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
      LuckyWeb::RouteHelper.new {{ method }}, path
    end
  end

  macro optional_param(param)
    {% OPTIONAL_PARAMS << param.id %}

    def {{ param }}
      params.get?(:{{ param }})
    end
  end
end
