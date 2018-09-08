require "../../spec_helper"

include ContextHelper

class Cookies::Index < Lucky::Action
  get "/cookies" do
    better_cookies.set :my_cookie, "cookie"
    better_session.set :my_session, "session"    

    text "#{better_cookies.get(:my_cookie).value} - #{better_session.get(:my_session)}"
  end
end

class PreCookies::Index < Lucky::Action
  get "/pre_cookies" do
    text "#{better_cookies.get?(:my_cookie).value}"
  end
end

describe Lucky::Action do
  describe "reading set cookies and sessions" do
    it "can set and read cookies" do
      response = Cookies::Index.new(build_context, params).call

      response.body.should eq "cookie - session"
    end
  end

  describe "reading a cookie valie that isn't there" do
    it "will initialize the cookies object and not crash" do
      response = PreCookies::Index.new(build_context, params).call

      response.body.should eq ""
    end
  end
end
