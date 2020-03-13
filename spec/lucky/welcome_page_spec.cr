require "../spec_helper"

include ContextHelper

describe Lucky::WelcomePage do
  it "compiles successfully" do
    html = Lucky::WelcomePage.new(context: build_context).render.to_s
    html.should contain("Welcome to Lucky")
  end
end
