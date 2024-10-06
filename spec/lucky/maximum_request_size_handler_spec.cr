require "../spec_helper"
require "http/server"

include ContextHelper

describe Lucky::MaximumRequestSizeHandler do
  context "when the handler is disabled" do
    it "simply serves the request" do
      context = build_small_request_context("/path")
      Lucky::MaximumRequestSizeHandler.temp_config(enabled: false) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::OK)
    end
  end

  context "when the handler is enabled" do
    it "with a small request, serve the request" do
      context = build_small_request_context("/path")
      Lucky::MaximumRequestSizeHandler.temp_config(enabled: true) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::OK)
    end

    it "with a large request, deny the request" do
      context = build_large_request_context("/path")
      Lucky::MaximumRequestSizeHandler.temp_config(enabled: true) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::PAYLOAD_TOO_LARGE)
    end
  end
end

private def run_request_size_handler(context)
  handler = Lucky::MaximumRequestSizeHandler.new
  handler.next = ->(_ctx : HTTP::Server::Context) {}
  handler.call(context)
end

private def build_small_request_context(path : String) : HTTP::Server::Context
  build_context(path: path)
end

private def build_large_request_context(path : String) : HTTP::Server::Context
  build_context(path: path).tap do |context|
    context.request.headers["Content-Length"] = "1000000"
    context.request.body = "a" * 1000000
  end
end
