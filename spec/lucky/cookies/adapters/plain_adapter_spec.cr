require "../../../spec_helper"

include ContextHelper

describe Lucky::Adapters::PlainAdapter do
  it "writes" do
    context = build_context
    cookie_jar = Lucky::CookieJar.new
    cookie_jar.set :email, "test@example.com"
    adapter = Lucky::Adapters::PlainAdapter.new

    adapter.write("my_key", cookie_jar, to: context.response)

    cookies = HTTP::Cookies.from_headers(context.response.headers)
    cookies["my_key"].value.should eq({"email" => "test@example.com"}.to_json)
  end

  it "reads" do
  end
end
