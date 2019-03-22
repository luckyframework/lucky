require "../../spec_helper"

include ContextHelper

class FrameGuardRoutes::WithSameorigin < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_value
    "sameorigin"
  end
end

class FrameGuardRoutes::WithDeny < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_value
    "deny"
  end
end

class FrameGuardRoutes::WithURL < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_value
    "https://tacotrucks.food"
  end
end

class FrameGuardRoutes::WithBadValue < Lucky::Action
  include Lucky::SecureHeaders::SetFrameGuard

  get "/so_custom" do
    text "test"
  end

  def frame_guard_value
    "hax0rz"
  end
end

describe Lucky::SecureHeaders do
  describe "SetFrameGuard" do
    it "sets the X-Frame-Options header with sameorigin" do
      route = FrameGuardRoutes::WithSameorigin.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "sameorigin"
    end

    it "sets the X-Frame-Options header with deny" do
      route = FrameGuardRoutes::WithDeny.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "deny"
    end

    it "sets the X-Frame-Options header to allow from tacotrucks" do
      route = FrameGuardRoutes::WithURL.new(build_context, params).call
      route.context.response.headers["X-Frame-Options"].should eq "allow-from https://tacotrucks.food"
    end

    it "throws an error when given a bad value" do
      expect_raises(Exception) do
        route = FrameGuardRoutes::WithBadValue.new(build_context, params).call
      end
    end
  end
end
