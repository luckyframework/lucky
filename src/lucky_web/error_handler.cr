class LuckyWeb::ErrorHandler
  include HTTP::Handler

  Habitat.create do
    setting show_debug_output : Bool = false
  end

  private getter action

  def initialize(@action : LuckyWeb::ErrorAction.class)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    if settings.show_debug_output
      print_debug_output(context, error)
    else
      call_error_action(context, error)
    end
  end

  private def print_debug_output(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    context.response.reset
    context.response.status_code = 500
    context.response.content_type = "text/plain"
    context.response.print("ERROR: ")
    error.inspect_with_backtrace(context.response)
    context
  end

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    action.new(context).perform_action(error)
    context
  end
end
