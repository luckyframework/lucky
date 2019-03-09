class Lucky::ErrorHandler
  include HTTP::Handler

  Habitat.create do
    setting show_debug_output : Bool
  end

  private getter action, error_io

  def initialize(@action : Lucky::ErrorAction.class, @error_io : IO = STDERR)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    call_error_action(context, error)
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

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    status_code = status_code_by_error(error)
    context.response.status_code = status_code
    action.new(context).perform_action(error)
    context
  end

  private def status_code_by_error(error : Lucky::HttpRespondable)
    error.http_error_code
  end

  private def status_code_by_error(error : Exception)
    Lucky::Action::Status::InternalServerError.value
  end
end
