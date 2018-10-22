require "../spec_helper"

include ContextHelper

private class FakeError < Exception
end

private class UnhandledError < Exception
end

private class InvalidParam < Lucky::Exceptions::InvalidParam
end

private class FakeErrorAction < Lucky::ErrorAction
  def handle_error(error : FakeError)
    head status: 404
  end

  def handle_error(error : Exception)
    text "Oops"
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

  it "returns a 422 status for InvalidParam exceptions" do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) {
      raise InvalidParam.new(
        param_name: "page",
        param_value: "select%201+1",
        param_type: "Int32")
    }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("text/plain")
    context.response.status_code.should eq(422)
  end

  context "when configured to show debug output" do
    it "prints debug output instead of calling the error action" do
      Lucky::ErrorHandler.temp_config(show_debug_output: true) do
        fake_io = IO::Memory.new
        error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction, error_io: fake_io)
        error_handler.next = ->(_ctx : HTTP::Server::Context) { raise UnhandledError.new }

        context = error_handler.call(build_context).as(HTTP::Server::Context)

        context.response.headers["Content-Type"].should eq("text/html")
        context.response.status_code.should eq(500)
        fake_io.to_s.should contain("UnhandledError")
        fake_io.to_s.should contain("from spec/lucky/error_handling_spec.cr")
      end
    end
  end
end
