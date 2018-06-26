require "./error_action"
require "./debug/debug_action"

class Lucky::ErrorHandler
  include HTTP::Handler

  Habitat.create do
    setting show_debug_output : Bool
  end

  private getter action

  def initialize(@action : Lucky::ErrorAction.class)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    if settings.show_debug_output
      status_code = 500
      context.response.reset
      context.response.status_code = status_code
      Lucky::DebugAction.new(context).perform_action(error, status_code)
      context
    else
      call_error_action(context, error)
    end
  end

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    context.response.status_code = 500
    action.new(context).perform_action(error)
    context
  end
end
