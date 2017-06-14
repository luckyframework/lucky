![github banner-short](https://user-images.githubusercontent.com/22394/26989908-dd99cc2c-4d22-11e7-9576-c6aeada2bd63.png)

A web framework for Crystal

## Installation

1. Install the Lucky CLI: https://github.com/luckyframework/cli#installing-the-cli
1. Run `lucky init`
1. Type `web` when it asks you what you would like to generate
1. Run `lucky dev` to start the server

## Hello World

```crystal
# src/actions/tasks/index.cr
class Tasks::Index < BaseAction
  get "/" do
    text "Hello World!"
  end
end
```

Run `lucky dev`, and visit `localhost:8000` and you should see "Hello World!"

That's pretty boring though, let's make something a bit more fancy

```crystal
# src/action/tasks/index.cr (the same file)
def call
  tasks = ["Clean room", "Play Titanfall 2"]
  render tasks: tasks
end
```

Now we need to create a page to generate HTML

```crystal
# src/pages/tasks/index_page.cr
class Tasks::IndexPage < BasePage
  # This makes it so you can pass tasks when rendering this view
  assigns tasks : Array(String)

  render do
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
class Task < BaseModel
  table :tasks do
    field :title
    field :description
  end
end
```

Now let's set up the database

1. Run `lucky db.create` to create the db
2. Run `lucky gen.migration CreateTasks`

```crystal
# db/migrations/xxxxx_create_tasks.cr
class CreateTasks::VXXXXX < LuckyMigrator::Migration::V1
  def up
    create_table :tasks do
      # Timestamps and primary key are automatically added
      add String :title # Since there is no `?` this field is marked as NULL false in the db
      add String? :description # Using `?` will make this nullable
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
# src/actions/tasks/index.cr
class Tasks::Index < Lucky::BaseAction
  get "/" do
    tasks = Task::BaseQuery.all # Get all tasks from the database
    render tasks: tasks
  end
end
```

We need to change the view a bit

```crystal
class Tasks::IndexPage < BasePage
  # Change this to get an array of Tasks
  assigns tasks : Task::BaseQuery

  render do
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
# src/actions/tasks/new.cr
class Tasks::New < App::BaseAction
  # The route is automatically inferred from the class name
  # In this case it is "/tasks/new"
  action do
    task = TaskForm.new
    render task: task
  end
end
```

And a view

```crystal
class Tasks::NewPage < BasePage
  assigns task : TaskForm

  def call
    h1 "Create a new task"
    form_for url: Task::Create.route do
      text_field task.title_field
      text_field task.desription_field

      submit_button
    end
  end
end
```

This won't work though since we need a Form. A Form is what validates and saves record to the database. Let's create one for our task.

```crystal
# src/forms/task_form.cr
# This base class is auto generated from our Task model
class TaskForm < Task::BaseForm
  allow :title, :description # only these fields can be set from params

  # This is called before anything else. You can set up validations, modify fields, etc.
  def process
    validate_required title, description
  end
end
```

Now we should have a form. Let's add a create action to actually save our task

??? Maybe add generator `lucky gen.action Tasks::CreateAction`

```crystal
# src/actions/tasks/create.cr
class Tasks::Create < BaseAction
  # Route is inferred as `POST /tasks`
  action do
    # The changeset will automatically get the right param name, so pass the full `params`
    TaskForm.save params do |form, task|
      if task
        flash[:success] = "This is cool"
        redirect to: Tasks::IndexAction.route
      else
        flash[:error] = "Nooooo!"
        render NewPage, task: form # This will render Tasks::NewPage
      end
    end
  end
end
```

Let's make sure we show errors in our new form view

```crystal
class Tasks::NewHtmlView < App::BaseHtmlView
  assigns task : TaskForm

  def call
    flash_errors if flash[:error]?
    task_errors if !task.errors.empty?
    h1 "Create a new task"
    form_for url: Task::Create.route do
      text_field task.title_field
      text_field task.desription_field

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

Note: None of these helpers are written yet

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
