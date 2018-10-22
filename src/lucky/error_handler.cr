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
    if settings.show_debug_output
      print_debug_output(context, error)
    else
      call_error_action(context, error)
    end
  end

  private def print_debug_output(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    error.inspect_with_backtrace(error_io)
    render_exception_page(context, error)
    context
  end

  private def render_exception_page(context, error)
    context.response.reset
    context.response.status_code = 500
    context.response.content_type = "text/html"
    context.response.print Lucky::ExceptionPage.for_runtime_exception(context, error)
  end

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    status_code = status_code_by_error(error)
    context.response.status_code = status_code
    action.new(context).perform_action(error)
    context
  end

  private def status_code_by_error(error : Exception)
    case error
    when Lucky::Exceptions::InvalidParam
      Lucky::Action::Status::UnprocessableEntity.value
    else
      Lucky::Action::Status::InternalServerError.value
    end
  end
end
