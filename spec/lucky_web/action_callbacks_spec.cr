require "../../spec_helper"

include ContextHelper

class CallbackFromActionMacro::Index < LuckyWeb::Action
  before set_before_cookie

  action do
    render_text "Body"
  end

  def set_before_cookie
    cookies["before"] = "before"
    continue
  end
end

abstract class InheritableCallbacks < LuckyWeb::Action
  before set_before_cookie
  after overwrite_after_cookie

  def set_before_cookie
    cookies["before"] = "before"
    continue
  end

  def overwrite_after_cookie
    cookies["after"] = "after"
    continue
  end
end

class Callbacks::Index < InheritableCallbacks
  before set_second_before_cookie
  after set_second_after_cookie

  get "/callbacks" do
    cookies["after"] = "This should be overwritten by the after ballback"
    render_text "not_from_callback"
  end

  def set_second_before_cookie
    cookies["second_before"] = "second_before"
    continue
  end

  def set_second_after_cookie
    cookies["second_after"] = "second_after"
    continue
  end
end

class Callbacks::HaltedBefore < LuckyWeb::Action
  before redirect_me
  before should_not_be_reached

  get "/before_callbacks" do
    render_text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_before"
  end

  def should_not_be_reached
    cookies["before"] = "nope"
    continue
  end
end

class Callbacks::HaltedAfter < LuckyWeb::Action
  after redirect_me
  after should_not_be_reached

  get "/after_callbacks" do
    render_text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_after"
  end

  def should_not_be_reached
    cookies["after"] = "nope"
    continue
  end
end

describe LuckyWeb::Action do
  it "works with actions that use the `action` macro" do
    response = CallbackFromActionMacro::Index.new(build_context, params).call
    response.context.cookies["before"].should eq "before"
  end

  describe "handles before callbacks" do
    it "runs through all the callbacks if no LuckyWeb::Response is returned" do
      response = Callbacks::Index.new(build_context, params).call

      response.body.should eq "not_from_callback"
      response.context.cookies["before"].should eq "before"
      response.context.cookies["second_before"].should eq "second_before"
      response.context.cookies["after"].should eq "after"
      response.context.cookies["second_after"].should eq "second_after"
    end

    it "halts before callbacks if a LuckyWeb::Response is returned" do
      response = Callbacks::HaltedBefore.new(build_context, params).call

      response.body.should eq ""
      response.context.response.status_code.should eq 302
      response.context.response.headers["Location"].should eq "/redirected_in_before"
      response.context.cookies["before"].should be_nil
    end

    it "halts after callbacks if a LuckyWeb::Response is returned" do
      response = Callbacks::HaltedAfter.new(build_context, params).call

      response.body.should eq ""
      response.context.response.status_code.should eq 302
      response.context.response.headers["Location"].should eq "/redirected_in_after"
      response.context.cookies["after"].should be_nil
    end
  end
end
