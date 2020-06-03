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

  it "redirects back" do
    request = build_request("POST")
    request.headers["Referer"] = "https://www.example.com/coming/from"
    action = RedirectAction.new(build_context(request), params)
    action.redirect_back fallback: "/fallback"
    should_redirect(action, to: "https://www.example.com/coming/from", status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect_back fallback: "/fallback"
    should_redirect(action, to: "/fallback", status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect_back fallback: RedirectAction.route
    should_redirect(action, to: RedirectAction.path, status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect_back fallback: RedirectAction
    should_redirect(action, to: RedirectAction.path, status: 302)

    action = RedirectAction.new(build_context, params)
    action.redirect_back fallback: RedirectAction, status: 301
    should_redirect(action, to: RedirectAction.path, status: 301)
  end

  it "turbolinks redirects after a XHR POST form submission" do
    request = build_request("POST")
    request.headers["Accept"] = "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01"
    request.headers["X-Requested-With"] = "XmlHttpRequest"
    context = build_context("/", request: request)

    action = RedirectAction.new(context, params)
    response = action.redirect to: "/somewhere", status: 302
    should_redirect(action, to: "/somewhere", status: 200)
    action.context.response.headers.has_key?("Turbolinks-Location").should be_false
    response.body.should eq %[Turbolinks.clearCache();\nTurbolinks.visit("/somewhere", {"action": "replace"})]
  end

  it "set a cookie for redirects occurring during a turbolinks GET request" do
    request = build_request
    request.headers["Turbolinks-Referrer"] = "/"
    context = build_context("/", request: request)

    action = RedirectAction.new(context, params)
    response = action.redirect to: "/somewhere", status: 302
    should_redirect(action, to: "/somewhere", status: 302)
    context.response.headers.has_key?("Turbolinks-Location").should be_false
    response.body.should eq ""
    # should remember redirect to
    context.cookies.get?(:_turbolinks_location).should eq "/somewhere"
  end

  it "restore turbolinks redirect target" do
    context = build_context
    context.cookies.set(:_turbolinks_location, "/somewhere")

    RedirectAction.new(context, params).call
    context.response.status_code.should eq 200
    context.response.headers["Turbolinks-Location"].should eq "/somewhere"
    context.cookies.deleted?(:_turbolinks_location).should be_true
  end
end

private def should_redirect(action, to path, status)
  action.context.response.headers["Location"].should eq path
  action.context.response.status_code.should eq status
end
