require "../../../spec_helper"

include ContextHelper

describe Lucky::Adapters::PlainAdapter do
  describe "#write" do
    it "writes to the cookie" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      cookie_jar.set :email, "test@example.com"
      adapter = Lucky::Adapters::PlainAdapter.new

      adapter.write("my_key", cookie_jar, to: context.response)

      cookies = HTTP::Cookies.from_headers(context.response.headers)
      cookies["my_key"].value.should eq({"email" => "test@example.com"}.to_json)
    end

    it "sets the Set-Cookie header" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      cookie_jar.set :email, "test@example.com"
      encoded = URI.escape({"email" => "test@example.com"}.to_json)
      adapter = Lucky::Adapters::PlainAdapter.new
      key = "my_key"

      adapter.write(key, cookie_jar, to: context.response)
      headers = context.response.headers

      headers["Set-Cookie"].should eq("my_key=#{encoded}; path=/")
    end
  end

  it "reads" do
    context = build_context
    cookie_jar = Lucky::CookieJar.new
    cookie_jar.set :email, "test@example.com"
    context.request.cookies["my_key"] = cookie_jar.to_json
    context.request.cookies.add_request_headers(context.request.headers)
    adapter = Lucky::Adapters::PlainAdapter.new

    new_cookie_jar = adapter.read("my_key", from: context.request)

    new_cookie_jar.get(:email).should eq "test@example.com"
  end
end
