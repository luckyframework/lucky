require "../../spec_helper"

describe Lucky::CookieJar do
  it "sets and gets with indifferent access" do
    jar = Lucky::CookieJar.empty_jar

    jar.set(:symbol_key, "symbol key")
    jar.set("string_key", "string key")
    jar[:another_symbol] = "symbol key"
    jar["another_string"] = "string key"

    jar.get(:symbol_key).should eq("symbol key")
    jar.get("symbol_key").should eq("symbol key")
    jar.get("string_key").should eq("string key")
    jar.get(:string_key).should eq("string key")
    jar[:another_symbol].should eq("symbol key")
    jar["another_string"].should eq("string key")
  end

  it "sets and gets raw HTTP::Cookie object with indifferent access" do
    value = "Nestle_Tollhouse"
    jar = Lucky::CookieJar.empty_jar

    jar.set_raw("cookie", value)
    jar.set_raw(:symbol, "symbol_value")

    jar.get_raw(:cookie).should be_a(HTTP::Cookie)
    jar.get_raw("symbol").value.should eq("symbol_value")
    jar.get_raw(:cookie).value.should eq(value)
    jar.get_raw("cookie").value.should eq(value)
    jar.get_raw?(:cookie).as(HTTP::Cookie).value.should eq(value)
    jar.get_raw?("cookie").as(HTTP::Cookie).value.should eq(value)
    jar.get_raw?(:missing).should be_nil
    jar.get_raw?("missing").should be_nil
  end

  it "raises a nicer error for invalid cookie values" do
    value = "Double Chocolate"
    jar = Lucky::CookieJar.empty_jar

    expect_raises(Lucky::InvalidCookieValueError, "Cookie value for 'cookie' is invalid") do
      jar.set_raw("cookie", value)
    end
  end

  it "raises CookieNotFoundError when getting a raw cookie that doesn't exist" do
    jar = Lucky::CookieJar.empty_jar

    expect_raises Lucky::CookieNotFoundError, "No cookie found with the key: 'snickerdoodle'" do
      jar.get_raw(:snickerdoodle)
    end
  end

  it "raises CookieNotFoundError when getting an encrypted cookie that doesn't exist" do
    jar = Lucky::CookieJar.empty_jar

    expect_raises Lucky::CookieNotFoundError, "No cookie found with the key: 'snickerdoodle'" do
      jar.get(:snickerdoodle)
    end
  end

  it "catches values with old or incorrect keys and returns nil" do
    jar_with_old_secret = Lucky::CookieJar.empty_jar
    Lucky::Server.temp_config(secret_key_base: "a" * 32) do
      jar_with_old_secret.set(:name, "value")
    end
    value_encrypted_with_old_jar = jar_with_old_secret.get_raw(:name).value
    jar = Lucky::CookieJar.empty_jar

    jar.set_raw(:name, value_encrypted_with_old_jar)

    jar.get?(:name).should be_nil
  end

  it "returns nil if fails to decrypt value" do
    jar = Lucky::CookieJar.empty_jar

    jar.set_raw(:name, "Jane")

    jar.get?(:name).should be_nil
  end

  it "parses encrypted cookies as expected" do
    # meant to be a regression test to make sure we don't
    # accidentally break cookie decryption
    #
    # this cookie was created with Lucky 0.27
    cookie_key = "cookie_key"
    cookie_value = "bHVja3k=--hY71kbRfob4pb9NS7wJpWKOBRhF+kwYPsHRQQanyXzGSKsCO6MIHCZfRBxDRqqm6"
    cookies = HTTP::Cookies.new
    cookies[cookie_key] = cookie_value
    jar = Lucky::CookieJar.from_request_cookies(cookies)

    JSON.parse(jar.get(cookie_key)).should eq({"key" => "value", "abc" => "123"})
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
        message.path.should be_nil
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
      jar.get_raw(:tabs_or_spaces).expires.as(Time).should eq(time)
    end

    it "raises an error if the cookie is > 4096 bytes" do
      expect_raises(Lucky::CookieOverflowError) do
        jar = Lucky::CookieJar.empty_jar
        jar.set_raw(:overflow, "x" * 4097) # "overflow=x...x; HttpOnly",
      end
    end
  end

  describe "delete" do
    # https://stackoverflow.com/questions/5285940/correct-way-to-delete-cookies-server-side
    it "expires the cookie and sets the value to an empty string" do
      jar = Lucky::CookieJar.empty_jar
      jar.set(:rules, "no fighting!")
      jar.get_raw(:rules).expired?.should_not be_true

      jar.delete(:rules)

      jar.get_raw(:rules).expired?.should be_true
      jar.get_raw(:rules).value.should eq("")
    end

    it "deletes a valid cookie with a block" do
      jar = Lucky::CookieJar.empty_jar
      jar.set(:rules, "no fighting!").domain("brawl.co")

      jar.delete(:rules) do |cookie|
        cookie.domain("brawl.co")
      end

      jar.deleted?(:rules).should be_true
    end

    it "ignores an invalid cookie when trying to delete" do
      jar = Lucky::CookieJar.empty_jar
      jar.set(:rules, "no fighting!").domain("brawl.co")

      jar.delete(:burritos) do |cookie|
        cookie.domain("brawl.co")
      end

      jar.deleted?(:rules).should be_false
    end
  end

  describe "deleted?" do
    it "returns true when the cookie looks like a deleted cookie" do
      jar = Lucky::CookieJar.empty_jar
      jar.set(:go, "now!")
      jar.deleted?(:go).should be_false

      jar.delete(:go)

      jar.deleted?(:go).should be_true
    end

    it "returns false when the cookie doesn't even exist" do
      jar = Lucky::CookieJar.empty_jar
      jar.deleted?(:non).should be_false
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

    it "deletes cookies with options" do
      headers = HTTP::Headers.new
      headers["Cookie"] = "name=Rick%20James"
      cookies = HTTP::Cookies.from_client_headers(headers)
      jar = Lucky::CookieJar.from_request_cookies(cookies)

      jar.clear do |cookie|
        cookie.path("/")
          .http_only(true)
          .secure(true)
          .domain(".example.com")
      end

      name = jar.get_raw(:name)
      name.value.should eq("")
      name.path.should eq("/")
      name.domain.should eq(".example.com")
      name.secure.should be_true
      name.expired?.should be_true
    end
  end
end
