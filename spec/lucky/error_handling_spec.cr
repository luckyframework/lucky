require "../spec_helper"

include ContextHelper

private class FakeError < Exception
end

private class UnhandledError < Exception
end

private class ShortAndStoutError < Exception
  include Lucky::HttpRespondable

  def http_error_code
    418
  end
end

private class InvalidParam < Lucky::Exceptions::InvalidParam
end

private class FakeErrorAction < Lucky::ErrorAction
  def handle_error(error : FakeError)
    head status: 404
  end

  def handle_error(error : Exception)
    plain_text "Oops"
  end
end

describe Lucky::ErrorHandler do
  it "does nothing if no errors are raised" do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) {}

    error_handler.call(build_context)
  end

  it "handles the error if there is a method for handling it" do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) { raise FakeError.new }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("")
    context.response.status_code.should eq(404)
  end

  it "falls back to generic error handling if there are no custom error handlers" do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) { raise UnhandledError.new }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("text/plain")
    context.response.status_code.should eq(500)
  end

  it "returns the defined status code if the raised exception defines one" do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) {
      raise ShortAndStoutError.new("I'm a little teapot")
    }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("text/plain")
    context.response.status_code.should eq(418)
  end

  describe ".render_exception_page" do
    it "returns a exception page as a response with a 500 status" do
      context = build_context
      error = Exception.new
      response = Lucky::ErrorHandler.render_exception_page(context, error)
      response.should be_a(Lucky::Response)
      response.status.should eq(500)
    end
  end
end
