require "../../spec_helper"

include ContextHelper

class CallbackFromActionMacro::Index < Lucky::Action
  before set_before_cookie

  route do
    text "Body"
  end

  def set_before_cookie
    better_cookies.set("before", "before")
    continue
  end
end

abstract class InheritableCallbacks < Lucky::Action
  before set_before_cookie
  after overwrite_after_cookie

  def set_before_cookie
    better_cookies.set("before", "before")
    continue
  end

  def overwrite_after_cookie
    better_cookies.set("after", "after")
    continue
  end
end

class Callbacks::Skipped < InheritableCallbacks
  skip set_before_cookie, overwrite_after_cookie

  get "/skipped-callbacks" do
    text "Body"
  end
end

class Callbacks::Index < InheritableCallbacks
  before set_second_before_cookie
  after set_second_after_cookie

  get "/callbacks" do
    better_cookies.set("after", "This should be overwritten by the after ballback")
    text "not_from_callback"
  end

  def set_second_before_cookie
    better_cookies.set("second_before", "second_before")
    continue
  end

  def set_second_after_cookie
    better_cookies.set("second_after", "second_after")
    continue
  end
end

class Callbacks::HaltedBefore < Lucky::Action
  before redirect_me
  before should_not_be_reached

  get "/before_callbacks" do
    text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_before"
  end

  def should_not_be_reached
    better_cookies.set("before", "nope")
    continue
  end
end

class Callbacks::HaltedAfter < Lucky::Action
  after redirect_me
  after should_not_be_reached

  get "/after_callbacks" do
    text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_after"
  end

  def should_not_be_reached
    better_cookies.set("after", "nope")
    continue
  end
end

class Callbacks::OrderDependent < Lucky::Action
  getter callback_data
  @callback_data = [] of String

  before dog
  before cat
  after red
  after yellow

  get "/order_dependent" do
    text "rendered"
  end

  def dog
    @callback_data << "dog"
    continue
  end

  def cat
    @callback_data << "cat"
    continue
  end

  def red
    @callback_data << "red"
    continue
  end

  def yellow
    @callback_data << "yellow"
    continue
  end
end

describe Lucky::Action do
  it "works with actions that use the `action` macro" do
    response = CallbackFromActionMacro::Index.new(build_context, params).call
    response.context.better_cookies.get("before").value.should eq "before"
  end

  it "can skip callbacks" do
    response = Callbacks::Skipped.new(build_context, params).call
    response.context.cookies["before"].should eq(nil)
    response.context.cookies["after"].should eq(nil)
  end

  describe "handles before callbacks" do
    it "runs through all the callbacks if no Lucky::Response is returned" do
      response = Callbacks::Index.new(build_context, params).call

      response.body.should eq "not_from_callback"
      response.context.better_cookies.get("before").value.should eq "before"
      response.context.better_cookies.get("second_before").value.should eq "second_before"
      response.context.better_cookies.get("after").value.should eq "after"
      response.context.better_cookies.get("second_after").value.should eq "second_after"
    end

    it "halts before callbacks if a Lucky::Response is returned" do
      response = Callbacks::HaltedBefore.new(build_context, params).call

      response.body.should eq ""
      response.context.response.status_code.should eq 302
      response.context.response.headers["Location"].should eq "/redirected_in_before"
      response.context.better_cookies.get?("before").should be_nil
    end

    it "halts after callbacks if a Lucky::Response is returned" do
      response = Callbacks::HaltedAfter.new(build_context, params).call

      response.body.should eq ""
      response.context.response.status_code.should eq 302
      response.context.response.headers["Location"].should eq "/redirected_in_after"
      response.context.better_cookies.get?("after").should be_nil
    end

    it "renders the callbacks in the order they were defined" do
      action = Callbacks::OrderDependent.new(build_context, params)
      response = action.call

      response.body.should eq "rendered"
      action.callback_data[0].should eq("dog")
      action.callback_data[1].should eq("cat")
      action.callback_data[2].should eq("red")
      action.callback_data[3].should eq("yellow")
    end
  end
end
