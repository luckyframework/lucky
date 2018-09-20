require "../../spec_helper"

describe Lucky::CookieJar do
  it "gets and sets with indifferent access" do
    jar = Lucky::CookieJar.new

    jar.set(:symbol_key, "symbol key")
    jar.set("string_key", "string key")

    jar.get(:symbol_key).value.should eq("symbol key")
    jar.get("symbol_key").value.should eq("symbol key")
    jar.get("string_key").value.should eq("string key")
    jar.get(:string_key).value.should eq("string key")
  end

  describe "#set" do
    it "sets a cookie's expiration date by default" do
      jar = Lucky::CookieJar.new

      jar.set(:message, "help i'm trapped in a cookie jar")

      expiration = jar.get(:message).expires.not_nil!
      # dirty hack because I can't get a time mocking lib to work
      # this works when I test just this file but not in the full suite
      # my guess is because the time set in the cookie jar is a constant that
      # is set at compile time, which ends taking more than 1 second to compile
      # 1 minute difference for a year seems reasonable for now
      expiration.should be_close(1.year.from_now, 1.minute)
    end

    it "can still override the expiration" do
      jar = Lucky::CookieJar.new

      jar.set(:occupation, "stealth vegetable").expires(3.days.from_now)

      expiration = jar.get(:occupation).expires.not_nil!
      expiration.should be_close(3.days.from_now, 1.second)
    end

    it "makes cookie HTTPOnly by default" do
      jar = Lucky::CookieJar.new

      jar.set(:music, "Get Lucky - Daft Punk")

      jar.get(:music).http_only.should be_true
    end

    it "can still override HTTPOnly" do
      jar = Lucky::CookieJar.new

      jar.set(:tabs_or_spaces, "stop it").http_only(false)

      jar.get(:tabs_or_spaces).http_only.should be_false
    end
  end

  describe "#clear" do
    it "sets the jar to an empty hash" do
      jar = Lucky::CookieJar.new
      jar.set(:name, "Edward")

      jar.clear

      jar.get?(:name).value.should be_nil
    end
  end

  describe "#changed?" do
    it "returns true when any cookie is set" do
      jar = Lucky::CookieJar.new

      jar.changed?.should be_false

      jar.set(:city, "Boston")

      jar.changed?.should be_true
    end
  end
end
