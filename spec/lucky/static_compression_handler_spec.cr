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

  it "calls next when content type isn't in Lucky::Server.gzip_content_types" do
    Lucky::Server.temp_config(gzip_enabled: true, gzip_content_types: %w(text/html)) do
      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "gzip"
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_true
    end
  end

  it "delivers the precompressed file when enabled" do
    Lucky::Server.temp_config(gzip_enabled: true) do
      output = IO::Memory.new
      context = build_context_with_io(output, path: PATH)

      context.request.method = "GET"
      context.request.headers["Accept-Encoding"] = "gzip"

      next_called = false
      call_handler_with(context) { next_called = true }

      next_called.should be_false
      context.response.close

      context.response.headers["Content-Encoding"].should eq "gzip"
      context.response.headers["Etag"].should eq etag
      output.to_s.ends_with?(File.read(gzip_path)).should be_true
    end
  end

  it "calls next when Accept-Encoding doesn't include gzip" do
    Lucky::Server.temp_config(gzip_enabled: true) do
      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "whatever"
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_true
    end
  end

  it "sends NOT_MODIFIED when file hasn't been modified" do
    Lucky::Server.temp_config(gzip_enabled: true) do
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

private def etag
  %{W/"#{File.info(gzip_path).modification_time.to_unix}"}
end

private def call_handler_with(context : HTTP::Server::Context, &block)
  handler = Lucky::StaticCompressionHandler.new(public_dir: public_dir)
  handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
