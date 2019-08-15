require "../spec_helper"

include ContextHelper

class RedirectAction < TestAction
  get "/redirect_test" do
    plain_text "does not matter"
  end
end

describe Lucky::Action do
  it "redirects" do
    action = RedirectAction.new(build_context, params)
    action.redirect to: "/somewhere"
    should_redirect(action, to: "/somewhere", status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect to: RedirectAction.route
    should_redirect(action, to: RedirectAction.path, status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect to: RedirectAction
    should_redirect(action, to: RedirectAction.path, status: 302)
  end

  it "redirects with custom status" do
    action = RedirectAction.new(build_context, params)
    action.redirect to: "/somewhere", status: 301
    should_redirect(action, to: "/somewhere", status: 301)

    action = RedirectAction.new(build_context, params)
    action.redirect to: "/somewhere", status: HTTP::Status::MOVED_PERMANENTLY
    should_redirect(action, to: "/somewhere", status: 301)

    action = RedirectAction.new(build_context, params)
    action.redirect to: "/somewhere", status: :moved_permanently
    should_redirect(action, to: "/somewhere", status: 301)
  end
end

private def should_redirect(action, to path, status)
  action.context.response.headers["Location"].should eq path
  action.context.response.headers["Turbolinks-Location"].should eq path
  action.context.response.status_code.should eq status
end
