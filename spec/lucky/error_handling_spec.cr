require "../spec_helper"

include ContextHelper

private class CustomError < Exception
end

private class StealthError < Exception
end

private class UnhandledError < Exception
end

# Can't be private because if it is Crystal won't let us use temp_config
class FakeErrorAction < Lucky::ErrorAction
  default_format :html
  dont_report [StealthError]

  Habitat.create do
    setting output : IO = IO::Memory.new
  end

  def render(error : CustomError) : Lucky::Response
    head status: 404
  end

  def default_render(error : Exception) : Lucky::Response
    plain_text "This is not a debug page", status: 500
  end

  def report(error : Exception) : Nil
    settings.output.print("Reported: #{error.class.name}")
  end
end

describe "Error handling" do
  describe "reporting" do
    it "calls the report method on the error action" do
      io = IO::Memory.new
      FakeErrorAction.temp_config(output: io) do
        handle_error(error: CustomError.new) do |_context, _output|
          io.to_s.should eq("Reported: CustomError")
        end
      end
    end

    it "can skip reporting some errors" do
      io = IO::Memory.new
      FakeErrorAction.temp_config(output: io) do
        handle_error(error: StealthError.new) do |_context, _output|
          io.to_s.should eq("")
        end
      end
    end
  end

  describe "ErrorAction" do
    describe "show_debug_output setting is true" do
      it "renders debug output if request accepts HTML" do
        handle_error(format: :html, show_debug_output: true, status_code: 500) do |context, output|
          context.response.headers["Content-Type"].should eq("text/html")
          output.should contain("code-explorer")
          output.should contain("Error 500")
          context.response.status_code.should eq(500)
        end
      end

      it "does not render debug output if request is not HTML" do
        handle_error(format: :json, show_debug_output: true, status_code: 500) do |context, output|
          context.response.headers["Content-Type"].should eq("text/plain")
          output.should_not contain("code-explorer")
          output.should contain("This is not a debug page")
          context.response.status_code.should eq(500)
        end
      end

      it "renders debug page with the error's status" do
        handle_error(format: :html, show_debug_output: true, error: CustomError.new, status_code: 404) do |context, output|
          context.response.headers["Content-Type"].should eq("text/html")
          output.should contain("code-explorer")
          output.should contain("Error 404")
          context.response.status_code.should eq(404)
        end
      end
    end

    describe "show_debug_output setting is false" do
      it "does not render debug output" do
        handle_error(format: :json, show_debug_output: false, status_code: 500) do |context, output|
          context.response.headers["Content-Type"].should eq("text/plain")
          output.should contain("This is not a debug page")
          context.response.status_code.should eq(500)
        end
      end
    end
  end

  describe "ErrorHandler" do
    it "does nothing if no errors are raised" do
      error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
      error_handler.next = ->(_ctx : HTTP::Server::Context) {}

      error_handler.call(build_context)
    end

    it "handles the error with an overloaded 'render' method if defined" do
      handle_error(error: CustomError.new, status_code: 404) do |context, _output|
        context.response.headers["Content-Type"].should eq("")
        context.response.status_code.should eq(404)
      end
    end

    it "falls back to 'default_render' if there is no 'render' method for the exception" do
      handle_error(error: UnhandledError.new, status_code: 500) do |context, output|
        output.should contain("This is not a debug page")
        context.response.headers["Content-Type"].should eq("text/plain")
        context.response.status_code.should eq(500)
      end
    end
  end
end

private def handle_error(
  format : Symbol = :html,
  show_debug_output : Bool = false,
  error : Exception = UnhandledError.new,
  status_code : Int32 = 200
)
  Lucky::ErrorHandler.temp_config(show_debug_output: show_debug_output) do
    error_handler = Lucky::ErrorHandler.new(action: FakeErrorAction)
    error_handler.next = ->(_ctx : HTTP::Server::Context) { raise error }
    io = IO::Memory.new
    context = build_context_with_io(io)
    context._clients_desired_format = format
    context.response.status_code = status_code

    context = error_handler.call(context).as(HTTP::Server::Context)

    context.response.close
    yield context, io.to_s
  end
end
