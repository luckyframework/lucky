class Tasks::IndexPage
  include LuckyWeb::HTMLPage

  needs tasks : Array(Task)
  needs flash : LuckyWeb::Flash::Store

  def render
    header do
      h1 "All my tasks"
      a "New task", href: Tasks::New.path
      @flash.each do |key, value|
        div class: "flash-#{key}" do
          text value
        end
      end
      tasks_list
    end
  end

  private def tasks_list
    ul do
      @tasks.each do |task|
        li do
          a task.title, href: Tasks::Show.path(task.id)
        end
      end
    end
  end
end
