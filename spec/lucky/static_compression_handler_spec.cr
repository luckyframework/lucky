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
    context.response.headers["Content-Encoding"]?.should_not eq "gzip"
  end

  it "calls next when content type isn't in Lucky::Server.gzip_content_types" do
    Lucky::Server.temp_config(gzip_enabled: true, gzip_content_types: %w[text/html]) do
      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "gzip"
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_true
      context.response.headers["Content-Encoding"]?.should_not eq "gzip"
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

      context.response.headers["Content-Encoding"].should eq "gzip"
      context.response.headers["Etag"].should eq etag
      output.close
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
      context.response.headers["Content-Encoding"]?.should_not eq "gzip"
    end
  end

  it "sends NOT_MODIFIED when file hasn't been modified" do
    Lucky::Server.temp_config(gzip_enabled: true) do
      first_context = build_context(path: PATH)
      first_context.request.method = "GET"
      first_context.request.headers["Accept-Encoding"] = "gzip"

      call_handler_with(first_context) { }

      last_modified = HTTP.parse_time(first_context.response.headers["Last-Modified"]).as(Time)

      context = build_context(path: PATH)
      context.request.headers["Accept-Encoding"] = "gzip"
      context.request.headers["If-Modified-Since"] = HTTP.format_time(last_modified + 1.hour)
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_false
      context.response.status.should eq HTTP::Status::NOT_MODIFIED
    end
  end

  it "does not serve precompressed files outside of the public dir" do
    with_file_outside_public_dir do |nested_public_dir|
      Lucky::Server.temp_config(gzip_enabled: true) do
        ["/../secret.css", "/%2e%2e/secret.css", "/..%2fsecret.css", "/..%5csecret.css", "/nested/../../secret.css"].each do |path|
          context = build_context(path: path)
          context.request.headers["Accept-Encoding"] = "gzip"
          next_called = false

          call_handler_with(context, public_dir: nested_public_dir) { next_called = true }

          next_called.should be_true
          context.response.headers["Content-Encoding"]?.should_not eq "gzip"
        end
      end
    end
  end

  it "calls next when the path contains a null byte" do
    Lucky::Server.temp_config(gzip_enabled: true) do
      context = build_context(path: "/#{PATH}%00")
      context.request.headers["Accept-Encoding"] = "gzip"
      next_called = false

      call_handler_with(context) { next_called = true }

      next_called.should be_true
      context.response.headers["Content-Encoding"]?.should_not eq "gzip"
    end
  end
end

private def with_file_outside_public_dir(&)
  root = File.tempname("static_compression_handler")
  nested_public_dir = File.join(root, "public")
  Dir.mkdir_p(nested_public_dir)
  File.write(File.join(root, "secret.css.gz"), "secret")

  begin
    yield nested_public_dir
  ensure
    FileUtils.rm_rf(root)
  end
end

private def public_dir
  File.expand_path("spec/fixtures")
end

private def gzip_path
  File.join(public_dir, "#{PATH}.gz")
end

private def etag
  %(W/"#{last_modified.to_unix}")
end

private def last_modified
  File.info(gzip_path).modification_time
end

private def call_handler_with(context : HTTP::Server::Context, public_dir : String = public_dir, &block)
  handler = Lucky::StaticCompressionHandler.new(public_dir: public_dir)
  handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
  context.response.close
end
