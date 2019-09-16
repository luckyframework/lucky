class Lucky::ErrorHandler
  include HTTP::Handler

  Habitat.create do
    setting show_debug_output : Bool
    setting logger : Dexter::Logger = Lucky.logger
  end

  private getter action

  def initialize(@action : Lucky::ErrorAction.class)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    call_error_action(context, error)
  end

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    settings.logger.error(exception: error.inspect_with_backtrace)
    action.new(context).perform_action(error)
    context
  end
end
