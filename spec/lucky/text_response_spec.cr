require "../spec_helper"

include ContextHelper

# Monkey patch HTTP::Server::Response to allow accessing the response body directly.
class HTTP::Server::Response
  getter body_io : IO = IO::Memory.new

  def write(slice : Bytes) : Nil
    @body_io.write slice

    previous_def
  end
end

describe Lucky::TextResponse do
  describe "#print" do
    context "flash" do
      it "writes the flash to the session" do
        context = build_context
        context.flash.success = "Yay!"
        context.flash.keep
        flash_json = {success: "Yay!"}.to_json

        print_response_with_body(context)

        context.session.get(Lucky::FlashStore::SESSION_KEY).should eq(flash_json)
      end

      it "only keeps the flash for one request" do
        context_1 = build_context
        now_json = {success: "Yay!"}.to_json
        context_1.session.set(Lucky::FlashStore::SESSION_KEY, now_json)
        next_json = context_1.flash.to_json

        context_1.flash.success.should eq("Yay!")

        print_response_with_body(context_1)

        context_2 = build_context
        context_2.session.set(Lucky::FlashStore::SESSION_KEY, next_json)

        context_2.flash.success.should eq("")
      end

      it "keeps the flash for the next request" do
        context_1 = build_context
        context_1.flash.success = "Yay!"
        context_1.flash.keep
        next_json = context_1.flash.to_json

        print_response_with_body(context_1)

        context_2 = build_context
        context_2.session.set(Lucky::FlashStore::SESSION_KEY, next_json)

        context_2.flash.success.should eq("Yay!")
      end
    end

    context "cookies" do
      it "sets a cookie" do
        context = build_context
        context.cookies.set(:email, "test@example.com")

        print_response_with_body(context)

        context.response.headers.has_key?("Set-Cookie").should be_true
        context.response.headers["Set-Cookie"].should contain("email=")
      end

      it "persist cookies across multiple requests using response headers from Lucky and request headers from the browser" do
        context_1 = build_context
        context_1.cookies.set(:email, "test@example.com")

        print_response_with_body(context_1)

        browser_request = build_request
        cookie_header = context_1.response.cookies.map do |cookie|
          cookie.to_cookie_header
        end.join(", ")
        browser_request.headers.add("Cookie", cookie_header)
        context_2 = build_context("/", request: browser_request)

        context_2.cookies.get(:email).should eq "test@example.com"
      end

      it "only writes updated cookies to the response" do
        request = build_request
        # set initial cookies via header
        request.headers.add("Cookie", "cookie1=value1; cookie2=value2")
        context = build_context("/", request: request)
        context.cookies.set_raw(:cookie2, "updated2")

        print_response_with_body(context)

        context.response.headers["Set-Cookie"].should contain("cookie2=updated2")
        context.response.headers["Set-Cookie"].should_not contain("cookie1")
      end

      it "sets a session" do
        context = build_context
        context.session.set(:email, "test@example.com")

        print_response_with_body(context)

        context.response.headers.has_key?("Set-Cookie").should be_true
        context.response.headers["Set-Cookie"].should contain("_app_session")
      end

      it "persists the session across multiple requests" do
        context_1 = build_context
        context_1.session.set(:email, "test@example.com")

        print_response_with_body(context_1)

        request = build_request
        cookie_header = context_1.response.cookies.map do |cookie|
          cookie.to_cookie_header
        end.join("; ")
        request.headers.add("Cookie", cookie_header)
        context_2 = build_context("/", request: request)
        print_response_with_body(context_2)

        context_2.session.get(:email).should eq("test@example.com")
      end

      it "writes all the proper headers when a cookie is set" do
        context = build_context
        context
          .cookies
          .set(:yo, "lo")
          .path("/awesome")
          .expires(Time.utc(2000, 1, 1))
          .domain("luckyframework.org")
          .secure(true)
          .http_only(true)

        print_response_with_body(context)

        header = context.response.headers["Set-Cookie"]
        header.should contain("path=/awesome")
        header.should contain("expires=Sat, 01 Jan 2000")
        header.should contain("domain=luckyframework.org")
        header.should contain("Secure")
        header.should contain("HttpOnly")
      end

      it "allows for cookies to be disabled" do
        context = build_context
        context.session.set(:email, "test@example.com")

        print_response_with_body(context, enable_cookies: false)

        context.response.headers.has_key?("Set-Cookie").should be_false
      end
    end

    context "status" do
      it "uses the default status if none is set" do
        context = build_context
        print_response(context, status: nil)
        context.response.status_code.should eq Lucky::TextResponse::DEFAULT_STATUS
      end

      it "uses the passed in status" do
        context = build_context
        print_response(context, status: 300)
        context.response.status_code.should eq 300
      end

      it "uses the response status if it's set, and Lucky::TextResponse status is nil" do
        context = build_context
        context.response.status_code = 300
        print_response(context, status: nil)
        context.response.status_code.should eq 300
      end

      it "prints no body with a head call" do
        context = build_context("HEAD")
        print_response_with_body(context, "Body", status: nil)
        context.request.method.should eq "HEAD"
        context.response.body_io.to_s.should eq("")
        context.response.status_code.should eq 200
      end
    end

    context "compression" do
      it "gzips if enabled" do
        Lucky::Server.temp_config(gzip_enabled: true) do
          output = IO::Memory.new
          context = build_context_with_io(output)
          context.request.headers["Accept-Encoding"] = "gzip"

          print_response_with_body(context, status: 200, body: "some body")
          context.response.close

          context.response.headers["Content-Encoding"].should eq "gzip"
          expected_io = IO::Memory.new
          Compress::Gzip::Writer.open(expected_io, &.print("some body"))
          output.to_s.ends_with?(expected_io.to_s).should be_true
        end
      end

      it "doesn't gzip when content type isn't in Lucky::Server.gzip_content_types" do
        Lucky::Server.temp_config(gzip_enabled: true) do
          output = IO::Memory.new
          context = build_context_with_io(output)
          context.request.headers["Accept-Encoding"] = "gzip"

          print_response_with_body(context, status: 200, body: "some body", content_type: "foo/bar")
          context.response.close

          context.response.headers["Content-Encoding"]?.should_not eq "gzip"
          output.to_s.ends_with?("some body").should be_true
        end
      end
    end
  end
end

private def print_response(context : HTTP::Server::Context, status : Int32?)
  print_response_with_body(context, "", status)
end

private def print_response_with_body(
  context : HTTP::Server::Context,
  body = "",
  status = 200,
  content_type = "text/html",
  enable_cookies = true
)
  Lucky::TextResponse.new(
    context,
    content_type,
    body,
    status: status,
    enable_cookies: enable_cookies
  ).print
end
