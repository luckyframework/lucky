require "lucky_cli"
require "./action_generator"

class Gen::Action::Api < LuckyCli::Task
  include Gen::ActionGenerator

  summary "Generate a new api action"

  def help_message
    <<-TEXT
    #{summary}

    Example:

      lucky gen.action.api Api::Users::Index
    TEXT
  end

  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "ApiAction")
  end
end
