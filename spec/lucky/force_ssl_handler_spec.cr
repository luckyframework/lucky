require "../spec_helper"
require "http/server"

include ContextHelper

describe Lucky::ForceSSLHandler do
  context "when the handler is disabled" do
    it "simply serves the request" do
      context = build_ssl_context(ssl: false)
      Lucky::ForceSSLHandler.temp_config(enabled: false) do
        run_force_ssl_handler context
      end

      context.response.status_code.should eq 200
      context.response.headers["Location"]?.should be_nil
    end
  end

  context "when the handler is enabled" do
    context "when the request is using SSL" do
      context "when HSTS is not configured" do
        it "simply serves the request" do
          context = build_ssl_context(ssl: true)
          run_force_ssl_handler context

          context.response.status_code.should eq 200
          context.response.headers["Location"]?.should be_nil
        end
      end

      context "when HSTS is configured" do
        it "adds an appropriate Strict-Transport-Security header to the response" do
          context = build_ssl_context(ssl: true)
          with_strict_transport_security({max_age: 180.days, include_subdomains: false}) do
            run_force_ssl_handler context
            context.response.headers["Strict-Transport-Security"].should eq "max-age=15552000"
          end

          context = build_ssl_context(ssl: true)
          with_strict_transport_security({max_age: 180.days, include_subdomains: true}) do
            run_force_ssl_handler context
            context.response.headers["Strict-Transport-Security"].should eq "max-age=15552000; includeSubDomains"
          end

          context = build_ssl_context(ssl: true)
          # Should work with Time::MonthSpan, which is returned when using 'year'
          with_strict_transport_security({max_age: 1.year, include_subdomains: false}) do
            run_force_ssl_handler context
            context.response.headers["Strict-Transport-Security"].should eq "max-age=31104000"
          end
        end
      end
    end

    context "when the request is not using SSL" do
      it "redirects to an SSL version of the request" do
        context = build_ssl_context(ssl: false)
        run_force_ssl_handler context

        context.response.status_code.should eq 308
        context.response.headers["Location"].should eq "https://example.com/path"
      end

      it "redirects using custom status" do
        context = build_ssl_context(ssl: false)
        Lucky::ForceSSLHandler.temp_config(redirect_status: 302) do
          run_force_ssl_handler context
        end

        context.response.status_code.should eq 302
        context.response.headers["Location"].should eq "https://example.com/path"
      end
    end
  end
end

private def with_strict_transport_security(args)
  Lucky::ForceSSLHandler.temp_config(strict_transport_security: args) do
    yield
  end
end

private def run_force_ssl_handler(context)
  handler = Lucky::ForceSSLHandler.new
  handler.next = ->(_ctx : HTTP::Server::Context) {}
  handler.call(context)
end

private def build_ssl_context(ssl : Bool) : HTTP::Server::Context
  build_context(path: "/path").tap do |context|
    context.request.headers["X-Forwarded-Proto"] = ssl ? "https" : "http"
    context.request.headers["Host"] = "example.com"
  end
end
