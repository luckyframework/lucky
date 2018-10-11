require "../spec_helper"

include ContextHelper

describe Lucky::TextResponse do
  describe "#print" do
    it "uses the default status if none is set" do
      context = build_context
      print_response(context, status: nil)
      context.response.status_code.should eq Lucky::TextResponse::DEFAULT_STATUS
    end

    it "uses the passed in status" do
      context = build_context
      print_response(context, status: 300)
      context.response.status_code.should eq 300
    end

    it "uses the response status if it's set, and Lucky::TextResponse status is nil" do
      context = build_context
      context.response.status_code = 300
      print_response(context, status: nil)
      context.response.status_code.should eq 300
    end

    it "prints no body with a head call" do
      context = build_context("HEAD")
      print_response_with_body(context, "Body", "text/plain", nil)
      context.request.method.should eq "HEAD"
      context.request.body.to_s.should eq ""
      context.response.status_code.should eq 200
      context.response.headers["Content-Type"].should eq "text/plain"
    end
  end
end

private def print_response(context : HTTP::Server::Context, status : Int32?)
  print_response_with_body(context, "", "", status)
end

private def print_response_with_body(context : HTTP::Server::Context, body : String = "", content_type : String = "", status : Int32? = nil)
  Lucky::TextResponse.new(context, content_type, body, status: status).print
end
