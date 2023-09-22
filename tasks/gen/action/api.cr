require "lucky_task"
require "./action_generator"

class Gen::Action::Api < LuckyTask::Task
  include Gen::ActionGenerator

  summary "Generate a new api action"
  help_message <<-TEXT
  #{task_summary}

  Example:

    lucky gen.action.api Api::Users::Index
  TEXT

  positional_arg :action_name, "The name of the action"
  switch :with_page, "This flag is used with gen.action.browser Only"

  def call
    render_action_template(output, inherit_from: "ApiAction")
    if with_page?
      output.puts "No page generated for ApiActions".colorize.red
    end
  end

  private def action_name
    name = previous_def
    if name.downcase.starts_with?("api")
      name
    else
      "Api::#{name}"
    end
  end
end
