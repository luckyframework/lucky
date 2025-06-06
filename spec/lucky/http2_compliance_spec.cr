require "../spec_helper"

include ContextHelper

# Helper to call action with HTTP/2 compliance handler
def call_with_http2_compliance(action_class, context = build_context)
  handler = Lucky::HTTP2ComplianceHandler.new
  response = nil
  
  handler.next = ->(ctx : HTTP::Server::Context) {
    response = action_class.new(ctx, {} of String => String).call
    # Manually trigger response printing to ensure headers are set
    if resp = response
      resp.print
    end
  }
  
  handler.call(context)
  response || raise "Response was nil"
end

class HTTP2ComplianceTestAction < TestAction
  include Lucky::SecureHeaders::SetFrameGuard
  include Lucky::SecureHeaders::SetXSSGuard
  include Lucky::SecureHeaders::SetCSPGuard
  include Lucky::SecureHeaders::SetSniffGuard
  include Lucky::SecureHeaders::DisableFLoC

  get "/http2_test" do
    context.response.headers["custom-test-header"] = "test-value"
    data "test content", content_type: "text/plain"
  end

  def frame_guard_value : String
    "deny"
  end

  def csp_guard_value : String
    "script-src 'self'"
  end
end

class HTTP2RedirectTestAction < TestAction
  get "/redirect_test" do
    redirect to: "/target"
  end
end

class HTTP2CSRFTestAction < TestAction
  include Lucky::ProtectFromForgery

  post "/csrf_test" do
    plain_text "protected"
  end
end

describe "HTTP/2 Header Compliance" do
  describe "response headers are lowercase with dashes" do
    it "ensures all secure headers follow HTTP/2 naming convention" do
      context = build_context
      route = call_with_http2_compliance(HTTP2ComplianceTestAction, context)

      # Verify security headers are lowercase
      context.response.headers.has_key?("x-frame-options").should be_true
      context.response.headers.has_key?("x-xss-protection").should be_true
      context.response.headers.has_key?("content-security-policy").should be_true
      context.response.headers.has_key?("x-content-type-options").should be_true
      context.response.headers.has_key?("permissions-policy").should be_true

      # Check what headers are actually set by the data response
      # The DataResponse sets these headers based on our source code review
    end

    it "ensures no uppercase headers exist" do
      context = build_context
      route = call_with_http2_compliance(HTTP2ComplianceTestAction, context)

      # These should NOT exist (uppercase/mixed-case versions)
      context.response.headers.has_key?("X-Frame-Options").should be_false
      context.response.headers.has_key?("X-XSS-Protection").should be_false
      context.response.headers.has_key?("Content-Security-Policy").should be_false
      context.response.headers.has_key?("X-Content-Type-Options").should be_false
      context.response.headers.has_key?("Permissions-Policy").should be_false
      context.response.headers.has_key?("Custom-Test-Header").should be_false
    end

    it "validates all headers match HTTP/2 naming pattern" do
      context = build_context
      route = call_with_http2_compliance(HTTP2ComplianceTestAction, context)

      context.response.headers.each do |name, value|
        # HTTP/2 headers must be lowercase
        name.should eq name.downcase
        # Should not contain underscores (use dashes instead)
        name.should_not match(/_/)
        # Should only contain lowercase letters, numbers, and dashes
        name.should match(/^[a-z0-9\-]+$/)
      end
    end

    it "ensures custom headers follow HTTP/2 convention" do
      context = build_context
      route = call_with_http2_compliance(HTTP2ComplianceTestAction, context)

      context.response.headers["custom-test-header"].should eq "test-value"
    end
  end

  describe "redirect headers are HTTP/2 compliant" do
    it "sets location header in lowercase" do
      context = build_context
      route = call_with_http2_compliance(HTTP2RedirectTestAction, context)

      context.response.headers.has_key?("location").should be_true
      context.response.headers.has_key?("Location").should be_false
      context.response.headers["location"].should eq "/target"
    end
  end

  describe "CSRF protection headers are HTTP/2 compliant" do
    it "uses lowercase x-csrf-token header" do
      context = build_context
      context.request.method = "POST"
      
      # The action will try to read from x-csrf-token header
      route = HTTP2CSRFTestAction.new(context, params)
      
      # Verify the constant is lowercase
      Lucky::ProtectFromForgery::SESSION_KEY.should eq "x-csrf-token"
    end
  end

  describe "compression headers are HTTP/2 compliant" do
    it "sets content-encoding header correctly" do
      context = build_context
      context.request.headers["accept-encoding"] = "gzip"
      
      handler = Lucky::HTTP2ComplianceHandler.new
      handler.next = ->(ctx : HTTP::Server::Context) {
        route = Lucky::TextResponse.new(
          ctx,
          content_type: "text/html",
          body: "test content"
        )
        
        # Enable gzip for this test
        Lucky::Server.temp_config(gzip_enabled: true, gzip_content_types: ["text/html"]) do
          route.print
        end
      }
      
      handler.call(context)
      context.response.headers.has_key?("content-encoding").should be_true
      context.response.headers.has_key?("Content-Encoding").should be_false
    end
  end
end