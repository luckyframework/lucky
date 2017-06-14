class Tasks::IndexPage < LuckyWeb::Page
  assign tasks : Array(Task)

  render do
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
