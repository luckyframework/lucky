class Tasks::IndexPage < LuckyWeb::HTMLView
  def render
    header do
      h1 "All my tasks"
      a "New task", href: Tasks::NewAction.route
      tasks_list
    end
  end

  private def tasks_list
    ul do
      TaskRows.all.each do |task|
        li do
          a task.title, href: Tasks::ShowAction.route(task.id)
        end
      end
    end
  end
end

class Tasks::NewPage < LuckyWeb::HTMLView
  def render
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::IndexAction.route
    end
  end
end
