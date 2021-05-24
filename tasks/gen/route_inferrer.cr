require "wordsmith"

class Lucky::RouteInferrer
  getter? nested_route
  getter action_class_name

  def initialize(@action_class_name : String, @nested_route : Bool = false)
  end

  def generate_inferred_route
    %(#{http_method} "#{path}")
  end

  private def http_method
    case action_name
    when "delete"
      :delete
    when "create"
      :post
    when "update"
      :put
    else
      :get
    end
  end

  private def path
    "/" + all_pieces.join("/")
  end

  private def all_pieces
    (namespace_pieces + parent_resource_pieces + resource_pieces).reject(&.empty?)
  end

  private def resource
    action_pieces[-2]
  end

  private def action_name
    action_pieces.last
  end

  private def namespace_pieces
    _namespace_pieces = action_pieces.reject { |piece| piece == action_name || piece == resource }
    if nested_route?
      _namespace_pieces.reject { |piece| piece == parent_resource_name }
    else
      _namespace_pieces
    end
  end

  private def resource_pieces
    case action_name
    when "index", "create"
      [resource]
    when "new"
      [resource, "new"]
    when "edit"
      [resource, resource_id_param_name, "edit"]
    when "show", "update", "delete"
      [resource, resource_id_param_name]
    else
      resource_error
    end
  end

  private def resource_id_param_name
    ":#{Wordsmith::Inflector.singularize(resource)}_id"
  end

  private def resource_error
    examples = "Users::Index # Index, Show, New, Create, Edit, Update, or Delete"

    raise <<-ERROR
      Could not infer route for #{action_class_name}

      Got:
        #{action_class_name} (missing a known resourceful action)

      Expected something like:
        #{examples}
    ERROR
  end

  private def parent_resource_pieces
    if nested_route?
      singularized_param_name = ":#{Wordsmith::Inflector.singularize(parent_resource_name)}_id"
      [parent_resource_name, singularized_param_name]
    else
      [] of String
    end
  end

  private def parent_resource_name
    action_pieces[-3]
  end

  private def action_pieces
    action_class_name.split("::").map(&.underscore)
  end
end
