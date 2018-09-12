require "./spec_helper"

include ContextHelper

describe Lucky::SessionHandler do
  it "sets a cookie" do
    context = build_context
    context.better_cookies.set(:email, "test@example.com")

    Lucky::SessionHandler.new.call(context)

    context.response.headers.has_key?("Set-Cookie").should be_true
    context.response.headers["Set-Cookie"].should contain("email=")
  end

  it "ensures the cookie has a far-future expiration date" do
    context = build_context
    context.better_cookies.set(:email, "test@example.com")

    Lucky::SessionHandler.new.call(context)

    cookies = HTTP::Cookies.from_headers(context.response.headers)
    cookies.each do |cookie|
      cookie.value = decrypt_cookie_value(cookie)
    end

    expiration = cookies["email"].expires.not_nil!
    expiration.should be_close(1.year.from_now, 1.second)
  end

  it "persists the cookies across multiple requests" do
    context_1 = build_context
    context_1.better_cookies.set(:email, "test@example.com")
    Lucky::SessionHandler.new.call(context_1)

    request = build_request
    cookie_header = context_1.response.cookies.map do |cookie|
      cookie.to_cookie_header
    end.join(", ")
    request.headers.add("Cookie", cookie_header)
    context_2 = build_context("/", request: request)

    context_2.better_cookies.get(:email).value.should eq "test@example.com"
  end

  it "sets a session" do
    context = build_context
    context.better_session.set(:email, "test@example.com")

    Lucky::SessionHandler.new.call(context)

    context.response.headers.has_key?("Set-Cookie").should be_true
    context.response.headers["Set-Cookie"].should contain("_app_session")
  end

  it "persists the session across multiple requests" do
    context_1 = build_context
    context_1.better_session.set(:email, "test@example.com")
    Lucky::SessionHandler.new.call(context_1)

    request = build_request
    cookie_header = context_1.response.cookies.map do |cookie|
      cookie.to_cookie_header
    end.join("; ")
    request.headers.add("Cookie", cookie_header)
    context_2 = build_context("/", request: request)
    Lucky::SessionHandler.new.call(context_2)

    context_2.better_session.get(:email).should eq("test@example.com")
  end
end

private def decrypt_cookie_value(cookie : HTTP::Cookie) : String
  encryptor = Lucky::MessageEncryptor.
    new(Lucky::Server.settings.secret_key_base)
  decoded = Base64.decode(cookie.value)
  String.new(encryptor.decrypt(decoded))
end
