require "../spec_helper"
require "http"

include ContextHelper

private PATH = "example.css"

describe Lucky::StaticCompressionHandler do
  it "calls next when not enabled" do
    context = build_context(path: PATH)
    context.request.headers["Accept-Encoding"] = "gzip"
    next_called = false

    call_handler_with(context) { next_called = true }

    next_called.should be_true
  end

  it "delivers the precompressed file when enabled" do
    Lucky::StaticCompressionHandler.temp_config(enabled: true) do
      output = IO::Memory.new
      context = build_context_with_io(output, path: PATH)

      context.request.method = "GET"
      context.request.headers["Accept-Encoding"] = "gzip"

      next_called = false
      call_handler_with(context) { next_called = true }

      next_called.should be_false
      context.response.close
      pp context.response.headers

      context.response.headers["Content-Encoding"].should eq "gzip"
      context.response.headers.has_key?("Etag").should be_true
      output.to_s.ends_with?(File.read(gzip_path)).should be_true
    end
  end

  it "calls next when not Accept-Encoding doesn't include gzip" do
    Lucky::StaticCompressionHandler.temp_config(enabled: true) do
      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "whatever"
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_true
    end
  end

  it "sends not modified when file hasn't been modified" do
    Lucky::StaticCompressionHandler.temp_config(enabled: true) do
      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "gzip"
      context.request.headers["If-Modified-Since"] = HTTP.format_time(Time.utc)
      next_called = false

      call_handler_with(context) { next_called = true }
      context.response.close

      context.response.status.should eq HTTP::Status::NOT_MODIFIED
    end
  end
end

private def public_dir
  File.expand_path("spec/fixtures")
end

private def gzip_path
  File.join(public_dir, "#{PATH}.gz")
end

private def call_handler_with(context : HTTP::Server::Context, &block)
  handler = Lucky::StaticCompressionHandler.new(public_dir: public_dir)
  handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
