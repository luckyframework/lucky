require "../../spec_helper"

describe Lucky::CookieJar do
  it "gets and sets with indifferent access" do
    jar = Lucky::CookieJar.empty_jar

    jar.set(:symbol_key, "symbol key")
    jar.set("string_key", "string key")

    jar.get(:symbol_key).should eq("symbol key")
    jar.get("symbol_key").should eq("symbol key")
    jar.get("string_key").should eq("string key")
    jar.get(:string_key).should eq("string key")
  end

  it "get_raw gets the raw HTTP::Cookie object with indifferent access" do
    value = "Nestle Tollhouse"
    jar = Lucky::CookieJar.empty_jar

    jar.set(:cookie, value)

    jar.get_raw(:cookie).should be_a(HTTP::Cookie)
    jar.get_raw(:cookie).value.should_not be_nil
    jar.get_raw("cookie").value.should_not be_nil
    jar.get_raw?(:cookie).not_nil!.value.should_not be_nil
    jar.get_raw?("cookie").not_nil!.value.should_not be_nil
    jar.get_raw?(:missing).should be_nil
    jar.get_raw?("missing").should be_nil
  end

  describe "#set" do
    it "sets a cookie's expiration date by default" do
      Lucky::CookieJar.temp_config(default_expiration: 1.month) do
        jar = Lucky::CookieJar.empty_jar

        jar.set(:message, "Help I'm trapped in a cookie jar")

        # dirty hack because I can't get a time mocking lib to work
        # this works when I test just this file but not in the full suite
        # my guess is because the time set in the cookie jar is a constant that
        # is set at compile time, which ends taking more than 1 second to compile
        # 1 minute difference for a year seems reasonable for now
        expiration = jar.get_raw(:message).expires.not_nil!
        expiration.should be_close(1.month.from_now, 1.minute)
      end
    end

    it "can still override the expiration" do
      jar = Lucky::CookieJar.empty_jar

      jar.set(:occupation, "stealth vegetable").expires(3.days.from_now)

      expiration = jar.get_raw(:occupation).expires.not_nil!
      expiration.should be_close(3.days.from_now, 1.second)
    end

    it "makes cookie HTTPOnly by default" do
      jar = Lucky::CookieJar.empty_jar

      jar.set(:music, "Get Lucky - Daft Punk")

      jar.get_raw(:music).http_only.should be_true
    end

    it "can still override HTTPOnly" do
      jar = Lucky::CookieJar.empty_jar

      jar.set(:tabs_or_spaces, "stop it").http_only(false)

      jar.get_raw(:tabs_or_spaces).http_only.should be_false
    end
  end

  describe "delete" do
    # https://stackoverflow.com/questions/5285940/correct-way-to-delete-cookies-server-side
    it "exipres the cookie and sets the value to an empty string" do
      jar = Lucky::CookieJar.empty_jar

      jar.set(:rules, "no fighting!")

      jar.get_raw(:rules).expired?.should_not be_true

      jar.delete(:rules)

      jar.get_raw(:rules).expired?.should be_true
      jar.get_raw(:rules).value.should eq("")
    end
  end

  describe "#clear" do
    it "deletes all the cookies in the jar" do
      jar = Lucky::CookieJar.empty_jar
      jar.set(:name, "Edward")
      jar.set(:age, "Super Old")

      jar.clear

      name = jar.get_raw(:name)
      age = jar.get_raw(:age)
      name.value.should eq("")
      age.value.should eq("")
      name.expired?.should be_true
      age.expired?.should be_true
    end
  end
end
