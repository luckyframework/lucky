class Tasks::IndexHTML < LuckyWeb::HTMLView
  def render
    header class: "test" do
      h1 "Tasks index"
      br
      a "new task", href: Tasks::NewAction.route
      ul do
        li "A cool task", href: Tasks::ShowAction.route("test_id")
      end
    end
  end
end

class Tasks::NewHTML < LuckyWeb::HTMLView
  def render
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::IndexAction.route
    end
  end
end
