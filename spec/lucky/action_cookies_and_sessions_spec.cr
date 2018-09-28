require "../../spec_helper"

include ContextHelper

class Cookies::Index < Lucky::Action
  get "/cookies" do
    cookies.set :my_cookie, "cookie"
    session.set :my_session, "session"

    text "#{cookies.get(:my_cookie).value} - #{session.get(:my_session)}"
  end
end

class PreCookies::Index < Lucky::Action
  get "/pre_cookies" do
    text "#{cookies.get?(:my_cookie).value}"
  end
end

class FlashCookies::Index < Lucky::Action
  get "/flash" do
    flash.success = "You did it!"

    text "#{flash.success}"
  end
end

describe Lucky::Action do
  describe "reading set cookies and sessions" do
    it "can set and read cookies" do
      response = Cookies::Index.new(build_context, params).call

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
