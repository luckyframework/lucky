require "../spec_helper"

include ContextHelper

describe Lucky::WelcomePage do
  it "compiles successfully" do
    Lucky::WelcomePage.new(context: build_context).tap(&.render).view.to_s
      .should contain("Welcome to Lucky")
  end
end
