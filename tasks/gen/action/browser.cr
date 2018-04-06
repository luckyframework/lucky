class Gen::Action::Browser < LuckyCli::Task
  include Gen::ActionGenerator

  banner "Generate a new browser action"

  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "BrowserAction")
  end
end
