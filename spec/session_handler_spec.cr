require "./spec_helper"

include ContextHelper

describe LuckyWeb::SessionHandler do
  it "sets a cookie" do
    context = build_context
    context.session[:listening] = "linkin park"

    LuckyWeb::SessionHandler.new.call(context)

    context.response.headers.has_key?("Set-Cookie").should be_true
  end

  context "session persist across different requests" do
    context "Cookies Store" do
      it "sets session value in controller" do
        context_1 = build_context
        context_1.session["name"] = "david"
        LuckyWeb::SessionHandler.new.call(context_1)

        request = build_request
        request.headers = context_1.response.headers
        context_2 = build_context("/", request: request)
        LuckyWeb::SessionHandler.new.call(context_2)

        context_2.session["name"].should eq "david"
      end
    end
  end
end
