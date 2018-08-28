require "../../../spec_helper"

include ContextHelper

describe Lucky::Adapters::EncryptedAdapter do
  describe "#write" do
    it "encrypts writes the cookie to the headers" do
      context = build_context
      cookie_jar = Lucky::CookieJar.new
      cookie_jar.set(:email, "test@example.com")
      json_cookie = cookie_jar.to_json
      adapter = Lucky::Adapters::EncryptedAdapter.new

      adapter.write("my_key", cookie_jar, to: context.response)

      cookies = HTTP::Cookies.from_headers(context.response.headers)
      decoded = Base64.decode(cookies["my_key"].value)
      decrypted = encryptor.decrypt(decoded)
      String.new(decrypted).should eq(json_cookie)
    end
  end

  describe "#read" do
    it "reads and decrypts the cookie from the headers" do
      cookie_jar = Lucky::CookieJar.new
      cookie_jar.set(:email, "test@example.com")
      request = build_request
      encrypted = encryptor.encrypt(cookie_jar.to_json)
      encoded = Base64.strict_encode(encrypted)
      request.cookies["my_key"] = encoded
      adapter = Lucky::Adapters::EncryptedAdapter.new

      new_cookie_jar = adapter.read("my_key", from: request)

      new_cookie_jar.get(:email).should eq("test@example.com")
    end
  end
end

private def encryptor
  Lucky::MessageEncryptor.
      new(Lucky::Server.settings.secret_key_base)
end