# LuckyWeb

A web framework for Crystal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  lucky_web:
    github: luckyframework/web
```

## Usage

```crystal
require "lucky_web"
```

## Hello World

```crystal
# src/web/tasks/index_action.cr
require "./index_html_view.cr"

class Tasks::IndexAction < App::BaseAction
  root_path # this action will be called when visiting "/" in your browser

  def call
    text "Hello World!"
  end
end
```

Run `lucky watch`, and visit `localhost:8000` and you should see "Hello World!"

That's pretty boring though, let's make something a bit more fancy

```crystal
# src/web/tasks/index.cr (the same file)

def call
  tasks = ["Clean room", "Play Titanfall 2"]
  render tasks: tasks
end
```

Now we need to create a view to generate HTML

```crystal
# src/web/tasks/index_html_view.cr
class Tasks::IndexHtmlView < App::HtmlView
  # This makes it so you can pass tasks when rendering this view
  assigns tasks : Array(String)

  def render
    section do
      ul do
        tasks.each do |task_name|
          li task_name
        end
      end
    end
  end
end
```

## Using a database

Let's create a new model for tasks so we can create, edit and delete them.

```
# src/models/task.cr
class Task < App::Record
  field :title
  field :description
end
```

Now let's set up the database

1. Run `lucky db.create` to create the db
2. Run `luckt gen.migration CreateTasks`

```crystal
# db/migrations/xxxxx_create_tasks.cr
class CreateTasks::VXXXXX < LuckyMigrator::Migration::V1
  def up
    create_table :tasks do
      # Timestamps and primary key are automatically added
      add_string :title, null: false
      add_string :description, null: false
    end
  end

  def down
    drop_table :tasks
  end
end
```

Let's run the migration with `lucky db.migrate`

Now in our index action let's get a list of real tasks

```crystal
# src/web/tasks/index_action.cr
class Tasks::IndexAction < Lucky::BaseAction
  root_path

  def call
    tasks = Task.rows.all # Get all tasks from the database
    render tasks: tasks
  end
end
```

We need to change the view a bit

```crystal
# src/web/tasks/index_html_view.cr
class Tasks::IndexHtmlView < App::HtmlView
  # Change this to get an array of Tasks
  assigns tasks : Task::Rows

  def render
    section do
      h1 "List all tasks"
      ul do
        tasks.each do |task|
          li "#{task.title} - #{task.description}"
        end
      end
    end
  end
end
```

Now you should see a blank list of tasks. Let's create an action for creating tasks

```crystal
# src/web/tasks/new_action.cr
class Tasks::NewAction < App::BaseAction
  # The route is automatically inferred from the class name
  # In this case it is "/tasks/new"
  def call
    task = Task::Changeset.new
    render task: task
  end
end
```

And a view

```crystal
class Tasks::NewHtmlView < App::BaseHtmlView
  assigns task : Task::Changeset

  def call
    h1 "Create a new task"
    form_for task, Task::CreateAction.route do |form|
      text_field form, task.title_field
      text_field form, task.desription_field

      submit_button
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/luckyframework/web/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
