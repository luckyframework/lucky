require "../spec_helper"
require "http/server"

include ContextHelper

describe Lucky::ForceSSLHandler do
  context "if using ssl" do
    it "does nothing" do
      context = build_context
      context.request.headers["X-Forwarded-Proto"] = "https"

      run_force_ssl_handler context

      context.response.status_code.should eq 200
      context.response.headers["Location"]?.should be_nil
    end
  end

  context "if not using ssl" do
    it "redirects to ssl version of the request" do
      context = build_context(path: "/path")
      context.request.headers["X-Forwarded-Proto"] = "http"
      context.request.headers["Host"] = "example.com"

      run_force_ssl_handler context

      context.response.status_code.should eq 308
      context.response.headers["Location"].should eq "https://example.com/path"
    end

    it "redirects using custom status" do
      context = build_context(path: "/path")
      context.request.headers["X-Forwarded-Proto"] = "http"
      context.request.headers["Host"] = "example.com"

      Lucky::ForceSSLHandler.temp_config(redirect_status: 302) do
        run_force_ssl_handler context
      end

      context.response.status_code.should eq 302
      context.response.headers["Location"].should eq "https://example.com/path"
    end

    it "does nothing if handler is disabled" do
      context = build_context(path: "/path")
      context.request.headers["X-Forwarded-Proto"] = "http"
      context.request.headers["Host"] = "example.com"

      Lucky::ForceSSLHandler.temp_config(enabled: false) do
        run_force_ssl_handler context
      end

      context.response.status_code.should eq 200
      context.response.headers["Location"]?.should be_nil
    end

    it "enables HSTS with 1 year max age and subdomains by default" do
      context = build_context(path: "/path")

      run_force_ssl_handler context

      context.response.headers["Strict-Transport-Security"].should eq "max-age=31536000; includeSubDomains"
    end

    it "allows setting hsts max-age to 180 days with no subdomains" do
      context = build_context(path: "/path")

      Lucky::ForceSSLHandler.temp_config(hsts: {max_age: 180.days, include_subdomains: false}) do
        run_force_ssl_handler context
      end

      context.response.headers["Strict-Transport-Security"].should eq "max-age=15552000"
    end
  end
end

private def run_force_ssl_handler(context)
  handler = Lucky::ForceSSLHandler.new
  handler.next = ->(_ctx : HTTP::Server::Context) {}
  handler.call(context)
end
