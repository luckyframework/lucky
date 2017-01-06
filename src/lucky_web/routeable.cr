module LuckyWeb::Routeable
  macro included
    LuckyWeb::Router.add(infer_path, {{@type.name.id}})
  end

  macro infer_path
    resource = {{@type.name.split("::").first.underscore}}
    action_name = {{@type.name.split("::").last.gsub(/Action/, "").underscore}}

    case action_name
    when "index"
      "/#{resource}"
    when "new"
      "/#{resource}/new"
    when "show"
      "/#{resource}/:id"
    else
      raise <<-ERROR
      Could not infer route for #{"{{@type.name}}".colorize(:red)}

      Got:
        #{"{{@type.name}}".colorize(:red)} #{"(missing a resourceful action)".colorize(:yellow)}

      Expected something like:
        ResourceName::#{"Index".colorize.mode(:underline)}Action # Index, Show, New, Create, Edit, Update, or Delete

      \n
      ERROR
    end
  end
end
