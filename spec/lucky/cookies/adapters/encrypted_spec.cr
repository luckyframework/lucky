require "../../../spec_helper"

include ContextHelper

describe Lucky::BetterCookies::Adapters::Encrypted do
  describe ".read" do
    it "returns a decrypted CookieJar" do
      a_value = encryptor.encrypt("some cookie value")
      a_value = Base64.strict_encode(a_value)
      b_value = encryptor.encrypt("another cookie value")
      b_value = Base64.strict_encode(b_value)
      request = build_request
      request.headers.add("Cookie", "a=#{a_value};")
      request.headers.add("Cookie", "b=#{b_value};")

      cookies = Lucky::BetterCookies::Adapters::Encrypted.read(from: request)

      cookies.get(:a).should eq("some cookie value")
      cookies.get(:b).should eq("another cookie value")
    end
  end
end

private def encryptor
  Lucky::MessageEncryptor.new(Lucky::Server.settings.secret_key_base)
end
