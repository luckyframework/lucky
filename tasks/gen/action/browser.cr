require "lucky_task"
require "./action_generator"
require "../page"

class Gen::Action::Browser < LuckyTask::Task
  include Gen::ActionGenerator

  summary "Generate a new browser action"
  help_message <<-TEXT
  #{task_summary}

  Optionally, you can pass the --with-page flag to generate
  a page for the Action.

  Example:

    lucky gen.action.browser Users::Index --with-page
  TEXT

  positional_arg :action_name, "The name of the action"
  switch :with_page, "Generate a Page matching this Action"

  def call
    render_action_template(output, inherit_from: "BrowserAction")
    if with_page?
      page_task = Gen::Page.new
      page_task.output = output
      page_task.print_help_or_call(args: ["#{action_name}Page"])
    end
  end
end
