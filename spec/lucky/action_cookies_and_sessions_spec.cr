require "../../spec_helper"

include ContextHelper

class Cookies::Index < Lucky::Action
  get "/cookies" do
    better_cookies.set :my_cookie, "cookie"
    text "#{better_cookies.get(:my_cookie)}"
  end
end

describe Lucky::Action do
  describe "routing" do
    it "can set and read cookies" do
      response = Cookies::Index.new(build_context, params).call

      response.body.should eq "cookie"
    end
  end
end
