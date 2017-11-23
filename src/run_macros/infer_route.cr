require "lucky_inflector"

class InferRoute
  getter? nested_route, singular
  getter action_class_name

  def initialize(@action_class_name : String, @nested_route : Bool, @singular : Bool = false)
  end

  def generate_inferred_route
    <<-ROUTE_CODE
    add_route :#{http_method},
      "#{path}",
      #{action_class_name}
    ROUTE_CODE
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
    if singular?
      singular_resource_pieces
    else
      plural_resource_pieces
    end
  end

  private def plural_resource_pieces
    case action_name
    when "index", "create"
      [resource]
    when "new"
      [resource, "new"]
    when "edit"
      [resource, ":id", "edit"]
    when "show", "update", "delete"
      [resource, ":id"]
    else
      resource_error
    end
  end

  private def singular_resource_pieces
    case action_name
    when "index"
      puts(
        <<-ERROR
        Could not infer route for #{action_class_name}

        Reason: Singular routes do not support an index action"
        ERROR
      )

      raise "Invalid Index action for singular resource"
    when "create", "show", "update", "delete"
      [resource]
    when "new"
      [resource, "new"]
    when "edit"
      [resource, "edit"]
    else
      resource_error
    end
  end

  private def resource_error
    examples =
      if singular?
        "Users::New # Show, New, Create, Edit, Update, or Delete"
      else
        "Users::Index # Index, Show, New, Create, Edit, Update, or Delete"
      end

    puts(
      <<-ERROR
      Could not infer route for #{action_class_name}

      Got:
        #{action_class_name} (missing a known resourceful action)

      Expected something like:
        #{examples}
      ERROR
    )

    raise "Problem inferring route"
  end

  private def parent_resource_pieces
    if nested_route?
      singularized_param_name = ":#{LuckyInflector::Inflector.singularize(parent_resource_name)}_id"
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

nested_route = ARGV[1] == "true"
singular = ARGV[2] == "true"

puts InferRoute.new(
  action_class_name: ARGV[0], nested_route: nested_route, singular: singular
).generate_inferred_route
