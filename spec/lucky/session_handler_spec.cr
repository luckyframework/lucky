require "../spec_helper"

include ContextHelper

describe Lucky::SessionHandler do
  it "sets a cookie" do
    context = build_context
    context.cookies.set(:email, "test@example.com")

    Lucky::SessionHandler.new.call(context)

    context.response.headers.has_key?("Set-Cookie").should be_true
    context.response.headers["Set-Cookie"].should contain("email=")
  end

  it "persists the cookies across multiple requests" do
    context_1 = build_context
    context_1.cookies.set(:email, "test@example.com")
    Lucky::SessionHandler.new.call(context_1)

    request = build_request
    cookie_header = context_1.response.cookies.map do |cookie|
      cookie.to_cookie_header
    end.join(", ")
    request.headers.add("Cookie", cookie_header)
    context_2 = build_context("/", request: request)

    context_2.cookies.get(:email).value.should eq "test@example.com"
  end

  it "sets a session" do
    context = build_context
    context.session.set(:email, "test@example.com")

    Lucky::SessionHandler.new.call(context)

    context.response.headers.has_key?("Set-Cookie").should be_true
    context.response.headers["Set-Cookie"].should contain("_app_session")
  end

  it "persists the session across multiple requests" do
    context_1 = build_context
    context_1.session.set(:email, "test@example.com")
    Lucky::SessionHandler.new.call(context_1)

    request = build_request
    cookie_header = context_1.response.cookies.map do |cookie|
      cookie.to_cookie_header
    end.join("; ")
    request.headers.add("Cookie", cookie_header)
    context_2 = build_context("/", request: request)
    Lucky::SessionHandler.new.call(context_2)

    context_2.session.get(:email).should eq("test@example.com")
  end

  it "does not write the cookies if the cookies haven't changed" do
    encryped = encryptor.encrypt("red")
    encoded = Base64.strict_encode(encryped)
    pre_cookies = HTTP::Cookies.new
    pre_cookies["color"] = encoded
    request = build_request
    pre_cookies.add_request_headers(request.headers)
    context = build_context(request: request)

    Lucky::SessionHandler.new.call(context)

    context.response.headers["Set-Cookie"]?.should be_nil
  end

  it "does not write the session if the session hasn't changed" do
    context = build_context
    context.cookies.set(:color, "red")

    Lucky::SessionHandler.new.call(context)

    context.response.headers["Set-Cookie"].should contain("color")
    context.response.headers["Set-Cookie"].should_not contain("_app_session")
  end
end

private def decrypt_cookie_value(cookie : HTTP::Cookie) : String
  decoded = Base64.decode(cookie.value)
  String.new(encryptor.decrypt(decoded))
end

private def encryptor
  Lucky::MessageEncryptor.new(Lucky::Server.settings.secret_key_base)
end
