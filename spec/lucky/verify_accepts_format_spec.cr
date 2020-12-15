require "../spec_helper"

include ContextHelper

private class ActionThatAcceptsHtml < Lucky::Action
  accepted_formats [:html], default: :html

  get "/test" do
    plain_text "yay"
  end

  property clients_desired_format : Symbol = :foo
end

# Test that the default is the first format if there is just one format.
private class ActionWithImplicitDefault < Lucky::Action
  accepted_formats [:html]

  get "/test2" do
    plain_text "yay"
  end

  property clients_desired_format : Symbol = :foo
end

private class ActionThatAcceptsAnyFormat < Lucky::Action
  get "/test3" do
    plain_text "yay"
  end

  property clients_desired_format : Symbol = :foo
end

private class ActionWithUnrecognizedFormat < Lucky::Action
  accepted_formats [:wut_is_this]

  get "/test4" do
    plain_text "not yay"
  end

  property clients_desired_format : Symbol = :foo
end

private class ChildHtmlAction < ActionThatAcceptsHtml
end

describe Lucky::VerifyAcceptsFormat do
  it "child inherits accepted_formats from parent" do
    override_format ChildHtmlAction, :html do |action|
      action.call.body.should eq("yay")
    end

    expect_raises Lucky::NotAcceptableError do
      override_format ChildHtmlAction, :not_accepted do |action|
        action.call
      end
    end
  end

  it "lets the request through if the format is accepted" do
    override_format ActionThatAcceptsHtml, :html do |action|
      action.call.body.should eq("yay")
    end
  end

  it "raises an error if the format is not accepted" do
    expect_raises Lucky::NotAcceptableError do
      override_format ActionThatAcceptsHtml, :not_accepted do |action|
        action.call
      end
    end
  end

  it "lets any format through if accepted_formats is not set" do
    override_format ActionThatAcceptsAnyFormat, :will_accept_anything do |action|
      action.call.body.should eq("yay")
    end
  end

  it "raises if given a format that Lucky doesn't recognize" do
    expect_raises Exception, ":wut_is_this" do
      override_format ActionWithUnrecognizedFormat, :not_used do |action|
        action.call
      end
    end
  end
end

private def override_format(action, format : Symbol)
  action = action.new(build_context, params)
  action.clients_desired_format = format
  yield action
end
