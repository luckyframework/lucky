require "../../../spec_helper"

include ContextHelper

describe Lucky::Adapters::PlainAdapter do
  describe "#write" do
    it "writes to the cookie" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      cookie_jar.set :email, "test@example.com"
      adapter = Lucky::Adapters::PlainAdapter.new

      adapter.write(cookie_jar, to: context.response)

      cookies = HTTP::Cookies.from_headers(context.response.headers)
      cookies["email"].value.should eq("test@example.com")
    end

    it "sets the Set-Cookie header" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      value = "test@example.com"
      cookie_jar.set :email, value
      escaped_value = URI.escape(value)
      adapter = Lucky::Adapters::PlainAdapter.new

      adapter.write(cookie_jar, to: context.response)
      headers = context.response.headers

      headers["Set-Cookie"].should eq("email=#{escaped_value}; path=/")
    end
  end

  it "reads" do
    context = build_context
    context.request.cookies["email"] = "test@example.com"
    context.request.cookies.add_request_headers(context.request.headers)
    adapter = Lucky::Adapters::PlainAdapter.new

    new_cookie_jar = adapter.read(from: context.request)

    new_cookie_jar.get(:email).should eq "test@example.com"
  end
end
