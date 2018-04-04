class Gen::Action::Browser < Gen::ActionGenerator
  def call(io : IO = STDOUT)
    render_action_template(io, inherit_from: "BrowserAction")
  end
end
