module LuckyWeb::Routeable
  macro get(path)
    add_route :get, {{path}}, {{@type.name.id}}

    def call
      {{yield}}
    end
  end

  macro nested_action
    infer_nested_route

    def call
      {{yield}}
    end
  end

  macro action
    infer_route

    def call
      {{yield}}
    end
  end

  macro infer_nested_route
    infer_route(true)
  end

  macro infer_route(has_parent = false)
    {% action_pieces = @type.name.split("::").map(&.underscore) %}

    {% if has_parent %}
      {% parent_resource_name = action_pieces[-3] %}
      {% singularized_param_name = ":#{parent_resource_name.gsub(/s$/, "").id}_id"}
      {{ parent_resource_pieces = [parent_resource_name, singularized_param_name] }}
    {% else %}
      {% parent_resource_pieces = [] of String %}
    {% end %}

    {% resource = action_pieces[-2].id %}
    {% action_name = action_pieces.last %}
    {% method = :get %}

    {% if ["index", "create"].includes? action_name %}
      {% resource_pieces = [resource] %}
    {% elsif action_name == "new" %}
      {% resource_pieces = [resource, "new"] %}
    {% elsif action_name == "edit" %}
      {% resource_pieces = [resource, ":id", "edit"] %}
    {% elsif ["show", "update", "delete"].includes? action_name %}
      {% resource_pieces = [resource, ":id"] %}
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

    {% namespace_pieces = action_pieces.reject { |piece| piece == action_name || piece == resource } %}
    {% if has_parent %}
      {% namespace_pieces = namespace_pieces.reject { |piece| piece == parent_resource_name } %}
    {% end %}

    {% all_pieces = (namespace_pieces + parent_resource_pieces + resource_pieces).reject(&.== "") %}

    add_route {{ method }},
      {{ "/" + all_pieces.join("/") }},
      {{ @type.name.id }}
  end

  macro add_route(method, path, action)
    LuckyWeb::Router.add({{method}}, {{path}}, {{@type.name.id}})

    {% path_parts = path.split("/").reject(&.empty?) %}
    {% path_params = path_parts.select(&.starts_with?(":")) %}

    def self.path(
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
      is_root_path = path == ""
      path = "/" if is_root_path
      path
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

      is_root_path = path == ""
      path = "/" if is_root_path
      LuckyWeb::RouteHelper.new {{method}}, path
    end
  end
end
