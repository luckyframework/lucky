class Gen::Action::Api < Gen::ActionGenerator
  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "ApiAction")
  end
end
