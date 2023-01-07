require "../spec_helper"

include ContextHelper

class PipeFromActionMacro::Index < TestAction
  before set_before_cookie

  get "/pipe_from_action_macro" do
    plain_text "Body"
  end

  def set_before_cookie
    cookies.set("before", "before")
    continue
  end
end

abstract class InheritablePipes < TestAction
  before set_before_cookie
  after overwrite_after_cookie

  def set_before_cookie
    cookies.set("before", "before")
    continue
  end

  def overwrite_after_cookie
    cookies.set("after", "after")
    continue
  end
end

class Pipes::Skipped < InheritablePipes
  skip set_before_cookie, overwrite_after_cookie

  get "/skipped_pipes" do
    plain_text "Body"
  end
end

class Pipes::Index < InheritablePipes
  before set_second_before_cookie
  after set_second_after_cookie

  get "/pipes" do
    cookies.set("after", "This should be overwritten by the after pipe")
    plain_text "not_from_pipe"
  end

  def set_second_before_cookie
    cookies.set("second_before", "second_before")
    continue
  end

  def set_second_after_cookie
    cookies.set("second_after", "second_after")
    continue
  end
end

class Pipes::HaltedBefore < TestAction
  before redirect_me
  before should_not_be_reached

  get "/before_pipes" do
    plain_text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_before"
  end

  def should_not_be_reached
    cookies.set("before", "nope")
    continue
  end
end

class Pipes::HaltedAfter < TestAction
  after redirect_me
  after should_not_be_reached

  get "/after_pipes" do
    plain_text "this should not be reached"
  end

  def redirect_me
    redirect to: "/redirected_in_after"
  end

  def should_not_be_reached
    cookies.set("after", "nope")
    continue
  end
end

class Pipes::OrderDependent < TestAction
  getter pipe_data
  @pipe_data = [] of String

  before dog
  before cat
  after red
  after yellow

  get "/order_dependent" do
    plain_text "rendered"
  end

  def dog
    @pipe_data << "dog"
    continue
  end

  def cat
    @pipe_data << "cat"
    continue
  end

  def red
    @pipe_data << "red"
    continue
  end

  def yellow
    @pipe_data << "yellow"
    continue
  end
end

describe Lucky::Action do
  it "works with actions that use the `action` macro" do
    response = PipeFromActionMacro::Index.new(build_context, params).call
    response.context.cookies.get("before").should eq "before"
  end

  it "can skip pipes" do
    response = Pipes::Skipped.new(build_context, params).call
    response.context.cookies.get?("before").should be_nil
    response.context.cookies.get?("after").should be_nil
  end

  describe "handles before pipes" do
    it "runs through all the pipes if no Lucky::Response is returned" do
      Lucky::ContinuedPipeLog.dexter.temp_config do |log_io|
        response = Pipes::Index.new(build_context, params).call

        log = log_io.to_s
        response.body.should eq "not_from_pipe"
        log.should contain("before")
        log.should contain("second_before")
        log.should contain("after")
        log.should contain("overwrite_after_cookie")
        response.context.cookies.get("before").should eq "before"
        response.context.cookies.get("second_before").should eq "second_before"
        response.context.cookies.get("after").should eq "after"
        response.context.cookies.get("second_after").should eq "second_after"
      end
    end

    it "halts before pipes if a Lucky::Response is returned" do
      Lucky::Log.dexter.temp_config do |log_io|
        response = Pipes::HaltedBefore.new(build_context, params).call

        log = log_io.to_s
        response.body.should eq ""
        response.context.response.status_code.should eq 302
        response.context.response.headers["Location"].should eq "/redirected_in_before"
        log.should contain("halted_by")
        log.should contain("redirect_me")
        response.context.cookies.get?("before").should be_nil
      end
    end

    it "halts after pipes if a Lucky::Response is returned" do
      Lucky::Log.dexter.temp_config do |log_io|
        response = Pipes::HaltedAfter.new(build_context, params).call

        log = log_io.to_s
        response.body.should eq ""
        response.context.response.status_code.should eq 302
        response.context.response.headers["Location"].should eq "/redirected_in_after"
        response.context.cookies.get?("after").should be_nil
        log.should contain("halted_by")
        log.should contain("redirect_me")
      end
    end

    it "renders the pipes in the order they were defined" do
      action = Pipes::OrderDependent.new(build_context, params)
      response = action.call

      response.body.should eq "rendered"
      action.pipe_data[0].should eq("dog")
      action.pipe_data[1].should eq("cat")
      action.pipe_data[2].should eq("red")
      action.pipe_data[3].should eq("yellow")
    end
  end

  describe "events" do
    it "publishes an event when continued" do
      events = [] of Lucky::Events::PipeEvent
      Lucky::Events::PipeEvent.subscribe do |event|
        events << event
      end
      Pipes::Index.new(build_context, params).call
      pipe_names = events.map(&.name)
      pipe_names.should contain("set_before_cookie")
      pipe_names.should contain("overwrite_after_cookie")
      pipe_names.should contain("set_second_before_cookie")
      pipe_names.should contain("set_second_after_cookie")
    end

    it "publishes an event on before when halted" do
      events = [] of Lucky::Events::PipeEvent
      Lucky::Events::PipeEvent.subscribe do |event|
        events << event
      end
      Pipes::HaltedBefore.new(build_context, params).call
      halted_pipe = events.find! { |e| e.name == "redirect_me" }
      halted_pipe.continued.should eq false
      halted_pipe.position.to_s.should eq "Before"
      halted_pipe.before?.should eq true
    end

    it "publishes an event on after when halted" do
      events = [] of Lucky::Events::PipeEvent
      Lucky::Events::PipeEvent.subscribe do |event|
        events << event
      end
      Pipes::HaltedAfter.new(build_context, params).call
      halted_pipe = events.find! { |e| e.name == "redirect_me" }
      halted_pipe.continued.should eq false
      halted_pipe.position.to_s.should eq "After"
      halted_pipe.after?.should eq true
    end
  end
end
