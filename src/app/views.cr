class Tasks::IndexPage < LuckyWeb::HTMLView
  assign tasks : Array(Task)

  def render
    header do
      h1 "All my tasks"
      a "New task", href: Tasks::New.path
      tasks_list
    end
  end

  private def tasks_list
    ul do
      tasks.each do |task|
        li do
          a task.title, href: Tasks::Show.path(task.id)
        end
      end
    end
  end
end

class Tasks::NewPage < LuckyWeb::HTMLView
  def render
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::Index.path
    end
  end
end
