require "../../../spec_helper"

include ContextHelper

describe Lucky::Adapters::PlainAdapter do
  describe "#write" do
    it "writes to the cookie to headers" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      value = "test@example.com"
      cookie_jar.set :email, "test@example.com"
      escaped_value = URI.escape(value)
      adapter = Lucky::Adapters::PlainAdapter.new

      adapter.write(cookie_jar, to: context.response)

      headers = context.response.headers
      cookies = HTTP::Cookies.from_headers(headers)
      
      headers["Set-Cookie"].should eq("email=#{escaped_value}; path=/")
      cookies["email"].value.should eq("test@example.com")
    end
  end

  describe "#read" do
    it "reads each cookie from the headers" do
      context = build_context
      context.request.cookies["email"] = "test@example.com"
      context.request.cookies.add_request_headers(context.request.headers)
      adapter = Lucky::Adapters::PlainAdapter.new

      new_cookie_jar = adapter.read(from: context.request)

      new_cookie_jar.get(:email).should eq("test@example.com")
    end
  end
end
