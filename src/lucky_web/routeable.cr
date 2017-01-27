module LuckyWeb::Routeable
  macro included
    ROUTE_SETTINGS = {route_defined: false}
  end

  macro get(path)
    add_route {{path}}, {{@type.name.id}}

    def call
      {{yield}}
    end
  end

  macro action
    {% unless ROUTE_SETTINGS[:route_defined] %}
      infer_route
    {% end %}

    def call
      {{yield}}
    end
  end

  macro infer_route
    {% resource = @type.name.split("::").first.underscore %}
    {% action_name = @type.name.split("::").last.underscore %}

    {% if action_name == "index" %}
      {% path = "/#{resource.id}" %}
    {% elsif action_name == "new" %}
      {% path = "/#{resource.id}/new" %}
    {% elsif action_name == "show" %}
      {% path = "/#{resource.id}/:id" %}
    {% else %}
      {% raise(
           <<-ERROR
        Could not infer route for #{@type.name}

        Got:
          #{@type.name} (missing a known resourceful action)

        Expected something like:
          Users::Index # Index, Show, New, Create, Edit, Update, or Delete
        ERROR
         ) %}
    {% end %}

    add_route {{path}}, {{@type.name.id}}
  end

  macro add_route(path, action)
    LuckyWeb::Router.add({{path}}, {{@type.name.id}})
    mark_route_defined

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}
    def self.route(
    {% for param in path_params %}
      {{param.gsub(/:/, "").id}},
    {% end %}
      )
      String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << {{part.gsub(/:/, "").id}}
          {% else %}
            path << {{part}}
          {% end %}
        {% end %}
      end
    end
  end

  macro mark_route_defined
    {% ROUTE_SETTINGS[:route_defined] = true %}
  end
end
