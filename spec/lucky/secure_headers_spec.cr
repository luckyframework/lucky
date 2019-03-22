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

class XSSGuardRoutes::Index < Lucky::Action
  include Lucky::SecureHeaders::SetXSSGuard

  get "/so_custom" do
    text "test"
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
      expect_raises(Exception, "You set frame_guard_value to hax0rz") do
        route = FrameGuardRoutes::WithBadValue.new(build_context, params).call
      end
    end
  end

  describe "SetXSSGuard" do
    it "sets the X-XSS-Protection for a modern browser" do
      route = XSSGuardRoutes::Index.new(build_context, params).call
      route.context.response.headers["X-XSS-Protection"].should eq "1; mode=block"
    end

    it "disables the X-XSS-Protection header on older IE browsers" do
      request = HTTP::Request.new("GET", "/so_custom")
      request.headers["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)"
      route = XSSGuardRoutes::Index.new(build_context("/so_custom", request), params).call
      route.context.response.headers["X-XSS-Protection"].should eq "0"
    end
  end
end
