class Gen::Action::Api < LuckyCli::Task
  include Gen::ActionGenerator

  banner "Generate a new api action"

  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "ApiAction")
  end
end
