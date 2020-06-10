require "../spec_helper"

include ContextHelper

class Cookies::Index < TestAction
  get "/cookies" do
    cookies.set :my_cookie, "cookie"
    session.set :my_session, "session"

    plain_text "#{cookies.get(:my_cookie)} - #{session.get(:my_session)}"
  end
end

class PreCookies::Index < TestAction
  get "/pre_cookies" do
    plain_text "#{cookies.get?(:my_cookie)}"
  end
end

class FlashCookies::Index < TestAction
  get "/flash" do
    flash.success = "You did it!"

    plain_text "#{flash.success}"
  end
end

class CookiesDisabled::Index < TestAction
  disable_cookies

  get "/no_cookies" do
    cookies.set :my_cookie, "cookie"

    plain_text ""
  end
end

describe Lucky::Action do
  context "with cookies enabled" do
    describe "reading set cookies and sessions" do
      it "can set and read cookies" do
        response = Cookies::Index.new(build_context, params).call

        response.enable_cookies.should be_true
        response.context.cookies.get("my_cookie").should eq("cookie")
        response.context.session.get("my_session").should eq("session")
        response.body.should eq "cookie - session"
      end
    end

    describe "reading a cookie value that isn't there" do
      it "will initialize the cookies object and not crash" do
        response = PreCookies::Index.new(build_context, params).call

        response.body.should eq ""
      end
    end

    describe "setting and reading the flash" do
      it "will initialize the cookies object and not crash" do
        response = FlashCookies::Index.new(build_context, params).call

        response.body.should eq "You did it!"
      end
    end
  end

  context "with cookies disabled" do
    it "does not set a cookies header" do
      response = CookiesDisabled::Index.new(build_context, params).call
      response.print

      response.context.response.headers.has_key?("Set-Cookie").should be_false
    end
  end
end
