module LuckyWeb::Routeable
  macro included
    ROUTE_SETTINGS = {route_defined: false}
  end

  macro get(path)
    add_route :get, {{path}}, {{@type.name.id}}

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
    {% method = :get %}

    {% if ["index", "create"].includes? action_name %}
      {% path = "/#{resource.id}" %}
    {% elsif action_name == "new" %}
      {% path = "/#{resource.id}/new" %}
    {% elsif action_name == "edit" %}
      {% path = "/#{resource.id}/:id/edit" %}
    {% elsif ["show", "update", "delete"].includes? action_name %}
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

    {% if action_name == "delete" %}
      {% method = :delete %}
    {% elsif action_name == "create" %}
      {% method = :post %}
    {% elsif action_name == "update" %}
      {% method = :put %}
    {% end %}

    add_route {{method}}, {{path}}, {{@type.name.id}}
  end

  macro add_route(method, path, action)
    LuckyWeb::Router.add({{method}}, {{path}}, {{@type.name.id}})
    mark_route_defined

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}

    def self.path(
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

    def self.route(
    {% for param in path_params %}
      {{param.gsub(/:/, "").id}},
    {% end %}
      )
      path = String.build do |path|
        {% for part in path_parts %}
          path << "/"
          {% if part.starts_with?(":") %}
            path << {{part.gsub(/:/, "").id}}
          {% else %}
            path << {{part}}
          {% end %}
        {% end %}
      end
      LuckyWeb::RouteHelper.new {{method}}, path
    end
  end

  macro mark_route_defined
    {% ROUTE_SETTINGS[:route_defined] = true %}
  end
end
