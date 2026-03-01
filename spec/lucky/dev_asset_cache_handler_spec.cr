require "../spec_helper"

include ContextHelper

describe Lucky::DevAssetCacheHandler do
  it "sets no-cache headers for static assets" do
    %w[/main.css /main.js /font.woff2 /image.png].each do |path|
      context = build_context(path: path)
      handler = Lucky::DevAssetCacheHandler.new(enabled: true)
      handler.next = ->(_ctx : HTTP::Server::Context) { }
      handler.call(context)

      context.response.headers["Cache-Control"]
        .should eq("no-store, no-cache, must-revalidate")
      context.response.headers["Expires"].should eq("0")
    end
  end

  it "does not set no-cache headers for non-static assets" do
    %w[/some/page].each do |path|
      context = build_context(path: path)
      handler = Lucky::DevAssetCacheHandler.new(enabled: true)
      handler.next = ->(_ctx : HTTP::Server::Context) { }
      handler.call(context)

      context.response.headers["Cache-Control"]?.should be_nil
      context.response.headers["Expires"]?.should be_nil
    end
  end

  it "does nothing if the handler is disabled" do
    context = build_context(path: "/main.css")
    handler = Lucky::DevAssetCacheHandler.new(enabled: false)
    handler.next = ->(_ctx : HTTP::Server::Context) { }
    handler.call(context)

    context.response.headers["Cache-Control"]?.should be_nil
    context.response.headers["Expires"]?.should be_nil
  end
end
