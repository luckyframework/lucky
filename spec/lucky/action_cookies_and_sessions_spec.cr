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

describe Lucky::Action do
  describe "reading set cookies and sessions" do
    it "can set and read cookies" do
      response = Cookies::Index.new(build_context, params).call

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
