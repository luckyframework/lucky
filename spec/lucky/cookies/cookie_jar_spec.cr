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
    it "only sets the name, http_only, and value if no 'on_set' block is set" do
      Lucky::CookieJar.temp_config(on_set: nil) do
        jar = Lucky::CookieJar.empty_jar

        jar.set(:message, "Help I'm trapped in a cookie jar")

        jar.get(:message).should eq("Help I'm trapped in a cookie jar")
        message = jar.get_raw(:message)
        message.http_only.should be_true
        message.expires.should be_nil
        message.path.should eq "/"
        message.domain.should be_nil
        message.secure.should be_false
      end
    end

    it "calls 'on_set' block if set" do
      time = 1.day.from_now
      block = ->(new_cookie : HTTP::Cookie) {
        new_cookie.expires(time)
        new_cookie.domain("example.com")
      }

      Lucky::CookieJar.temp_config(on_set: block) do
        jar = Lucky::CookieJar.empty_jar

        jar.set(:message, "Help I'm trapped in a cookie jar")

        message = jar.get_raw(:message)
        message.expires.should eq(time)
        message.domain.should eq("example.com")
      end
    end

    it "returns a cookie so you can override cookie settings" do
      time = 1.day.from_now
      jar = Lucky::CookieJar.empty_jar

      jar.set(:tabs_or_spaces, "stop it").http_only(false).expires(time)

      jar.get_raw(:tabs_or_spaces).http_only.should be_false
      jar.get_raw(:tabs_or_spaces).expires.not_nil!.should eq(time)
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
