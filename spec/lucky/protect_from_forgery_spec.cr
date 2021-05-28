require "../spec_helper"

include ContextHelper

class ProtectedAction::Index < TestAction
  include Lucky::ProtectFromForgery

  get "/protected_action" { plain_text "Passed" }
end

describe Lucky::ProtectFromForgery do
  it "sets a CSRF token if none was set" do
    context = build_context(method: "GET")

    ProtectedAction::Index.new(context, params).call

    (context.session.get("X-CSRF-TOKEN").size > 30).should be_true
  end

  it "continues if the token in the parameter is correct" do
    context = build_context(method: "POST")
    context.session.set("X-CSRF-TOKEN", "my_token")
    params = {"_csrf" => "my_token"}

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(200)
    response.body.should eq("Passed")
  end

  it "continues if the token in the header is correct" do
    context = build_context(method: "POST")
    context.session.set("X-CSRF-TOKEN", "my_token")
    context.request.headers["X-CSRF-TOKEN"] = "my_token"

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(200)
    response.body.should eq("Passed")
  end

  it "halts with 403 if the header token is incorrect" do
    context = build_context(method: "POST")
    context.session.set("X-CSRF-TOKEN", "my_token")
    context.request.headers["X-CSRF-TOKEN"] = "incorrect"

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(403)
    response.body.should eq("")
  end

  it "halts with 403 if the param token is incorrect" do
    context = build_context(method: "POST")
    context.session.set("X-CSRF-TOKEN", "my_token")
    params = {"_csrf" => "incorrect"}

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(403)
    response.body.should eq("")
  end

  it "halts with 403 if there is no token" do
    context = build_context(method: "POST")
    context.session.set("X-CSRF-TOKEN", "my_token")

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(403)
    response.body.should eq("")
  end

  it "halts with 403 if no CSRF token in the session" do
    context = build_context(method: "POST")

    response = ProtectedAction::Index.new(context, params).call

    response.status.should eq(403)
    response.body.should eq("")
  end

  it "lets allowed HTTP methods through without a token" do
    Lucky::ProtectFromForgery::ALLOWED_METHODS.each do |http_method|
      context = build_context(method: http_method)

      response = ProtectedAction::Index.new(context, params).call

      response.status.should eq(200)
      response.body.should eq("Passed")
    end
  end
end
