require "./*"

abstract class Lucky::ErrorAction
  include Lucky::ActionDelegates
  include Lucky::Renderable
  include Lucky::Redirectable
  include Lucky::Exposable

  macro inherited
    include Lucky::RequestTypeHelpers
  end

  getter context

  def initialize(@context : HTTP::Server::Context)
  end

  # :nodoc:
  # Accept all formats. ErrorAction should *always* work
  class_getter _accepted_formats = [] of Symbol

  abstract def render(error : Exception) : Lucky::Response

  def perform_action(error : Exception)
    # Always get the rendered error because it also includes the HTTP status.
    # We need the HTTP status to use in the debug page.
    response = render(error)
    ensure_response_is_returned(response)

    if html? && Lucky::ErrorHandler.settings.show_debug_output
      response = render_exception_page(error, response.status)
    end

    response.print
  end

  private def ensure_response_is_returned(response : Lucky::Response) : Lucky::Response
    response
  end

  private def ensure_response_is_returned(response)
    {% raise <<-ERROR
      You must return a Lucky::Response from 'render' in your error action.

      You can do that by using head, render, redirect, json, text, etc.

      Example:

        def render(error : Exception) : Lucky::Response
          # Returns a Lucky::Response
          # Could also be render, json, text, etc.
          head status: 500
        end
      ERROR
    %}
  end

  def render_exception_page(error : Exception, status : Int) : Lucky::Response
    context.response.reset
    Lucky::TextResponse.new(
      context: context,
      status: status,
      content_type: "text/html",
      body: Lucky::ExceptionPage.for_runtime_exception(context, error).to_s
    )
  end
end
