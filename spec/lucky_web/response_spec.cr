require "../spec_helper"

include ContextHelper

describe LuckyWeb::Response do
  describe "#print" do
    it "uses the default status if none is set" do
      context = build_context
      print_response(context, status: nil)
      context.response.status_code.should eq LuckyWeb::Response::DEFAULT_STATUS
    end

    it "uses the passed in status" do
      context = build_context
      print_response(context, status: 300)
      context.response.status_code.should eq 300
    end

    it "uses the response status if it's set, and LuckyWeb::Response status is nil" do
      context = build_context
      context.response.status_code = 300
      print_response(context, status: nil)
      context.response.status_code.should eq 300
    end
  end
end

private def print_response(context : HTTP::Server::Context, status : Int32?)
  LuckyWeb::Response.new(context, "", "", status: status).print
end
