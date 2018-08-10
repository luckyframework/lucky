require "../../spec_helper"

describe Lucky::CookieJar do
  it "gets and sets with indifferent access" do
    cookie_jar = Lucky::CookieJar.new

    cookie_jar.set :symbol_key, "symbol value"
    cookie_jar.set "string_key", "string key"

    cookie_jar.get(:symbol_key).should eq "symbol value"
    cookie_jar.get("symbol_key").should eq "symbol value"
    cookie_jar.get("string_key").should eq "string key"
    cookie_jar.get(:string_key).should eq "string key"
  end
end
