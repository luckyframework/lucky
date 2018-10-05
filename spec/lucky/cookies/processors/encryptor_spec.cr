require "../../../spec_helper"

include ContextHelper

describe Lucky::Cookies::Processors::Encryptor do
  describe ".read" do
    it "returns a decrypted CookieJar" do
      a_value = encrypt("some cookie value")
      b_value = encrypt("another cookie value")
      request = build_request
      request.headers.add("Cookie", "a=#{a_value};")
      request.headers.add("Cookie", "b=#{b_value};")

      cookies = Lucky::Cookies::Processors::Encryptor.read(from: request)

      cookies.get(:a).value.should eq("some cookie value")
      cookies.get(:b).value.should eq("another cookie value")
    end
  end

  describe ".call" do
    it "encrypts cookies Set-Cookie response header" do
      response = HTTP::Server::Response.new(IO::Memory.new)
      cookies = Lucky::CookieJar.new
      cookies.set(:a, "a_value")

      Lucky::Cookies::Processors::Encryptor.write(
        cookie_jar: cookies,
        to: response
      )

      response_cookies = HTTP::Cookies.from_headers(response.headers)
      encoded = response_cookies.first.value
      decoded = Base64.decode(encoded)
      decrypted = String.new(encryptor.decrypt(decoded))

      response.headers["Set-Cookie"].should contain("a=")
      decrypted.should eq("a_value")
    end
  end
end

private def encryptor
  Lucky::MessageEncryptor.new(Lucky::Server.settings.secret_key_base)
end

private def encrypt(value : String)
  Base64.strict_encode(encryptor.encrypt(value))
end
