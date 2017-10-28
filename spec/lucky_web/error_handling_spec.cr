require "../spec_helper"

include ContextHelper

private class FakeError < Exception
end

private class UnhandledError < Exception
end

private class FakeErrorAction < LuckyWeb::ErrorAction
  def handle_error(error : FakeError)
    head status: 404
  end

  def handle_error(error : Exception)
    head status: 500
  end
end

describe LuckyWeb::ErrorHandler do
  it "does nothing if no errors are raised" do
    error_handler = LuckyWeb::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(ctx : HTTP::Server::Context) {}

    error_handler.call(build_context)
  end

  it "handles the error if there is a method for handling it" do
    error_handler = LuckyWeb::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(ctx : HTTP::Server::Context) { raise FakeError.new }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("")
    context.response.status_code.should eq(404)
  end

  it "falls back to generic error handling if there are no custom error handlers" do
    error_handler = LuckyWeb::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(ctx : HTTP::Server::Context) { raise UnhandledError.new }

    context = error_handler.call(build_context).as(HTTP::Server::Context)

    context.response.headers["Content-Type"].should eq("")
    context.response.status_code.should eq(500)
  end

  context "when configured to show debug output" do
    it "prints debug output instead of calling the error action" do
      begin
        LuckyWeb::ErrorHandler.configure do
          settings.show_debug_output = true
        end

        error_handler = LuckyWeb::ErrorHandler.new(action: FakeErrorAction)
        error_handler.next = ->(ctx : HTTP::Server::Context) { raise UnhandledError.new }

        context = error_handler.call(build_context).as(HTTP::Server::Context)

        context.response.headers["Content-Type"].should eq("text/plain")
        context.response.status_code.should eq(500)
      ensure
        LuckyWeb::ErrorHandler.configure do
          settings.show_debug_output = false
        end
      end
    end
  end
end
