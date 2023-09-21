require "lucky_task"
require "teeplate"
require "./action_generator"
require "../page"

class Gen::Action::Browser < LuckyTask::Task
  include Gen::ActionGenerator

  summary "Generate a new browser action"

  positional_arg :action_name, "The name of the action"
  switch :with_page, "Generate a Page matching this Action"

  def help_message
    <<-TEXT
    #{summary}

    Example:

      lucky gen.action.browser Users::Index
    TEXT
  end

  def call
    render_action_template(output, inherit_from: "BrowserAction")
    if with_page?
      page_task = Gen::Page.new
      page_task.output = output
      page_task.print_help_or_call(args: ["#{action_name}Page"])
    end
  end
end
