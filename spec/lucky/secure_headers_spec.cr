require "../../spec_helper"

include ContextHelper

class FrameGuardRoutes::WithSame < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_options
    {allow_from: "same"}
  end
end

class FrameGuardRoutes::WithNowhere < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_options
    {allow_from: "nowhere"}
  end
end

class FrameGuardRoutes::WithURL < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_options
    {allow_from: "https://tacotrucks.food"}
  end
end

describe Lucky::SecureHeaders do
  describe "SetFrameGuard" do
    it "sets the X-Frame-Options header with sameorigin" do
      route = FrameGuardRoutes::WithSame.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "sameorigin"
    end

    it "sets the X-Frame-Options header with deny" do
      route = FrameGuardRoutes::WithNowhere.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "deny"
    end

    it "sets the X-Frame-Options header to allow from tacotrucks" do
      route = FrameGuardRoutes::WithURL.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "allow-from https://tacotrucks.food"
    end
  end
end
