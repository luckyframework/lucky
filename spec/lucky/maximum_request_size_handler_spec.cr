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
      Lucky::MaximumRequestSizeHandler.temp_config(
        enabled: true,
        max_size: 10,
      ) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::PAYLOAD_TOO_LARGE)
    end

    it "allows larger request bodies for specific actions" do
      context = build_request_context_with_body("/__max_request_size/large", 50_000, "POST")
      Lucky::MaximumRequestSizeHandler.temp_config(
        enabled: true,
        max_size: 10_000,
      ) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::OK)
    end

    it "enforces smaller limits on specific actions" do
      context = build_request_context_with_body("/__max_request_size/small", 1_000, "POST")
      Lucky::MaximumRequestSizeHandler.temp_config(
        enabled: true,
        max_size: 10_000,
      ) do
        run_request_size_handler(context)
      end
      context.response.status.should eq(HTTP::Status::PAYLOAD_TOO_LARGE)
    end
  end
end

private def run_request_size_handler(context)
  handler = Lucky::MaximumRequestSizeHandler.new
  handler.next = ->(_ctx : HTTP::Server::Context) { }
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

private def build_request_context_with_body(path : String, bytes : Int32, method : String = "POST") : HTTP::Server::Context
  request = HTTP::Request.new(method, path)
  request.headers["Content-Length"] = bytes.to_s
  request.body = "a" * bytes
  build_context(path: path, request: request)
end

private class LargeUploadAction < Lucky::Action
  set_request_body_limit 50_000

  def call : Lucky::Response
    plain_text "ok"
  end
end

private class SmallUploadAction < Lucky::Action
  set_request_body_limit 500

  def call : Lucky::Response
    plain_text "ok"
  end
end

Lucky.router.add :post, "/__max_request_size/large", LargeUploadAction
Lucky.router.add :post, "/__max_request_size/small", SmallUploadAction
