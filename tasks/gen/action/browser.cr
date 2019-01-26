require "lucky_cli"
require "teeplate"
require "./action_generator"

class Gen::Action::Browser < LuckyCli::Task
  include Gen::ActionGenerator

  summary "Generate a new browser action"

  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "BrowserAction")
  end
end
