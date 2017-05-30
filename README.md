![small navy full logo](https://cloud.githubusercontent.com/assets/22394/26591304/3cfe5e76-452b-11e7-95f4-37c3aa8d2542.png)

A web framework for Crystal

This is just a README to work as an outline for what I want to eventually do. There is no/very little code done.

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

class Tasks::Index < App::BaseAction
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

```crystal
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
class Tasks::Index < Lucky::BaseAction
  root_path

  def call
    tasks = Task::Rows.new.all # Get all tasks from the database
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
class Tasks::New < App::BaseAction
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
    form_for task, url: Task::CreateAction.route do |form|
      text_field form, task.title_field
      text_field form, task.desription_field

      submit_button
    end
  end
end
```

This won't work though since we need a Changeset. A Changeset is what validates and saves record to the database. Let's create one for our task.

```crystal
# src/changesets/task_changeset
# This base class is auto generated from our Task model
class Task::Changeset < Task::BaseChangeset
  allow :title, :description # only these fields can be set from params

  # This is called before anything else. You can set up validations, modify fields, etc.
  def process
    validate_required :title, :description
  end
end
```

Now we should have a form. Let's add a create action to actually save our task

??? Maybe add generator `lucky gen.action Tasks::CreateAction`

```crystal
# src/web/tasks/create_action.cr
class Tasks::Create < App::BaseAction
  # Route is inferred as `POST /tasks`
  def call
    # The changeset will automatically get the right param name, so pass the full `params`
    task = Task::Changeset.new(params)

    if task.insert
      flash[:success] = "This is cool"
      redirect to: Tasks::IndexAction.route
    else
      flash[:error] = "Nooooo!"
      render :new, task: task # This will render Tasks::NewHtmlView
    end
  end
end
```

Let's make sure we show errors in our new form view

```crystal
class Tasks::NewHtmlView < App::BaseHtmlView
  assigns task : Task::Changeset

  def call
    flash_errors if flash[:error]?
    task_errors if !task.errors.empty?
    h1 "Create a new task"
    form_for task, url: Task::CreateAction.route do |form|
      text_field form, task.title_field
      text_field form, task.desription_field

      submit_button
    end
  end

  private def flash_errors
    h2 flash[:error], class: "oopsies"
  end

  private def task_errors
    ul(class: "validation-errors") do
      task.errors.each do |error|
        li error.message, class: "validation-errors-message"
      end
    end
  end
end
```

Now if there are errors or flash messages they will be seen in the form

## Testing

Let's create a test for the tasks list

```crystal
# spec/web/tasks/index_action_spec.cr
require "action_helper.cr"

describe Tasks::IndexActionSpec do
  it "renders list of tasks"
    tasks = TasksBox.create_pair
    conn = LuckyWeb::Spec::Conn.new

    conn.request Tasks::IndexAction.route

    tasks.each do |task|
      conn.response.body.should include(tasks.title)
      conn.response.body.should include(tasks.description)
    end
  end
end
```

let's create a "box" for our tasks. this is a way to easily generate test data.

```crystal
# spec/support/boxes/task_box.cr
class TaskBox < App::Box
  def build
    task.new(title: "default", description: "something")
  end
end
```

The cool thing about this being a regular class is you can add methods to customize the objects. Note this is still very much a WIP. Not sure how this will work exactly.

```crystal
# spec/support/boxes/task_box.cr
class TaskBox < App::Box
  def build
    @record = task.new(title: "default", description: "something")
  end

  def completed
    @record.completed = true
  end
end

taskbox.build.completed
```

## customizing the spec connection

let's say for some connections you want to set a session.  let's create a custom connection

```crystal
# spec/support/app_conn.new
class App::Conn < LuckyWeb::Spec::Conn
  def sign_in_as(user)
    session.int[:current_user_id] = user.id
  end
end
```

Now in your tests you can do

```
conn = App::Conn.new.sign_in_as(user)
```

## Contributing

1. Fork it ( https://github.com/luckyframework/web/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
