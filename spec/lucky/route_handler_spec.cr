require "../spec_helper"

include ContextHelper

class SampleAction::Index < Lucky::Action
  get "/sample-action" do
    if html?
      text "html test"
    else
      text "not html"
    end
  end
end

describe Lucky::RouteHandler do
  describe "when it finds the SampleAction" do
    it "renders the html request" do
      output = IO::Memory.new
      context = build_context_with_io(output, path: "/sample-action")
      context.request.method = "GET"
      context.request.headers["Accept"] = "text/html"

      handler = Lucky::RouteHandler.new
      handler.next = ->(_ctx : HTTP::Server::Context) {}
      handler.call(context)
      context.response.close
      output.to_s.should contain "html test"
    end

    it "renders the html with a file extension" do
      output = IO::Memory.new
      context = build_context_with_io(output, path: "/sample-action.html")
      context.request.method = "GET"

      handler = Lucky::RouteHandler.new
      handler.next = ->(_ctx : HTTP::Server::Context) {}
      handler.call(context)
      context.response.close
      output.to_s.should contain "html test"
    end

    it "renders a non-html request with a file extension" do
      output = IO::Memory.new
      context = build_context_with_io(output, path: "/sample-action.json")
      context.request.method = "GET"

      handler = Lucky::RouteHandler.new
      handler.next = ->(_ctx : HTTP::Server::Context) {}
      handler.call(context)
      context.response.close
      output.to_s.should contain "not html"
    end
  end

  describe "when no action is found" do
    it "calls the next handler" do
      context = build_context(path: "/not-found")
      context.request.method = "GET"

      handler = Lucky::RouteHandler.new
      handler.next = ->(_ctx : HTTP::Server::Context) { _ctx.response.status_code = 404 }
      handler.call(context)
      context.response.status_code.should eq 404
    end
  end

  describe "when setting custom mime_extensions" do
    it "registers a custom request Content-Type" do
      Lucky::RouteHandler.temp_config(mime_extensions: {".taco" => "mealtime/🌮"}) do
        Lucky::RouteHandler.settings.mime_extensions.each do |ext, type|
          MIME.register(ext, type)
        end

        output = IO::Memory.new
        context = build_context_with_io(output, path: "/sample-action.taco")
        context.request.method = "GET"

        handler = Lucky::RouteHandler.new
        handler.next = ->(_ctx : HTTP::Server::Context) {}
        handler.call(context)
        context.request.headers["Content-Type"].should eq "mealtime/🌮"
        context.response.close
        output.to_s.should contain "not html"
      end
    end
  end
end
