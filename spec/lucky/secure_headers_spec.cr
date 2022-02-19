require "../spec_helper"

include ContextHelper

class FrameGuardRoutes::WithSameorigin < TestAction
  include Lucky::SecureHeaders::SetFrameGuard

  get "/secure_path1" do
    plain_text "test"
  end

  def frame_guard_value : String
    "sameorigin"
  end
end

class FrameGuardRoutes::WithDeny < TestAction
  include Lucky::SecureHeaders::SetFrameGuard

  get "/secure_path2" do
    plain_text "test"
  end

  def frame_guard_value : String
    "deny"
  end
end

class FrameGuardRoutes::WithURL < TestAction
  include Lucky::SecureHeaders::SetFrameGuard

  get "/secure_path3" do
    plain_text "test"
  end

  def frame_guard_value : String
    "https://tacotrucks.food"
  end
end

class FrameGuardRoutes::WithBadValue < TestAction
  include Lucky::SecureHeaders::SetFrameGuard

  get "/secure_path4" do
    plain_text "test"
  end

  def frame_guard_value : String
    "hax0rz"
  end
end

class XSSGuardRoutes::Index < TestAction
  include Lucky::SecureHeaders::SetXSSGuard

  get "/secure_path5" do
    plain_text "test"
  end
end

class SniffGuardRoutes::Index < TestAction
  include Lucky::SecureHeaders::SetSniffGuard

  get "/secure_path6" do
    plain_text "test"
  end
end

class FLoCGGuardRoutes::Index < TestAction
  include Lucky::SecureHeaders::DisableFLoC

  get "/secure_path7" do
    plain_text "test"
  end
end

class CSPGuardRoutes::Index < TestAction
  include Lucky::SecureHeaders::SetCSPGuard

  get "/secure_path8" do
    plain_text "test"
  end

  def csp_guard_value : String
    "script-src 'self'"
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
        FrameGuardRoutes::WithBadValue.new(build_context, params).call
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

  describe "SetSniffGuard" do
    it "sets the X-Content-Type-Options to nosniff" do
      route = SniffGuardRoutes::Index.new(build_context, params).call
      route.context.response.headers["X-Content-Type-Options"].should eq "nosniff"
    end
  end

  describe "DisableFLoC" do
    it "sets the Permissions-Policy to interest-cohort=()" do
      route = FLoCGGuardRoutes::Index.new(build_context, params).call
      route.context.response.headers["Permissions-Policy"].should eq "interest-cohort=()"
    end
  end

  describe "SetCSPGuard" do
    it "sets the Content-Security-Policy header" do
      route = CSPGuardRoutes::Index.new(build_context, params).call
      route.context.response.headers["Content-Security-Policy"].should eq "script-src 'self'"
    end
  end
end
