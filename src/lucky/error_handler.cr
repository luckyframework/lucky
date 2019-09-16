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

  def self.render_exception_page(context, error)
    context.response.reset
    Lucky::TextResponse.new(
      context: context,
      status: 500,
      content_type: "text/html",
      body: Lucky::ExceptionPage.for_runtime_exception(context, error).to_s
    )
  end
end
