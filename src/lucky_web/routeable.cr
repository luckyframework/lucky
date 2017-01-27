module LuckyWeb::Routeable
  macro included
    add_route_and_helpers
  end

  macro add_route_and_helpers
    {% resource = @type.name.split("::").first.underscore %}
    {% action_name = @type.name.split("::").last.gsub(/Action/, "").underscore %}

    {% if action_name == "index" %}
      {% path = "/#{resource.id}" %}
    {% elsif action_name == "new" %}
      {% path = "/#{resource.id}/new" %}
    {% else %}
      {% raise(
           <<-ERROR
        Could not infer route for #{@type.name}

        Got:
          #{@type.name} (missing a known resourceful action)

        Expected something like:
          ResourceName::IndexAction # Index, Show, New, Create, Edit, Update, or Delete
        ERROR
         ) %}
    {% end %}

    LuckyWeb::Router.add({{path}}, {{@type.name.id}})
    # case action_name
    # when "index"
    #   "/#{resource}"
    # when "new"
    #   "/#{resource}/new"
    # when "show"
    #   "/#{resource}/:id"
    # else
    #   raise <<-ERROR
    #   Could not infer route for #{"{{@type.name}}".colorize(:red)}
    #
    #   Got:
    #     #{"{{@type.name}}".colorize(:red)} #{"(missing a resourceful action)".colorize(:yellow)}
    #
    #   Expected something like:
    #     ResourceName::#{"Index".colorize.mode(:underline)}Action # Index, Show, New, Create, Edit, Update, or Delete
    #
    #   \n
    #   ERROR
    # end
  end
end
