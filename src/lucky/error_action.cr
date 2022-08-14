require "./*"

abstract class Lucky::ErrorAction
  include Lucky::ActionDelegates
  include Lucky::ParamHelpers
  include Lucky::Renderable
  include Lucky::Redirectable
  include Lucky::Exposable

  macro inherited
    include Lucky::RequestTypeHelpers
  end

  getter context

  def _dont_report
    [] of Exception.class
  end

  macro dont_report(exception_classes)
    {% if exception_classes.is_a?(ArrayLiteral) %}
      def _dont_report
        {{ exception_classes }} of Exception.class
      end
    {% else %}
      {% exception_classes.raise "dont_report expects an array of Exception classes." %}
    {% end %}
  end

  def initialize(@context : HTTP::Server::Context)
  end

  # :nodoc:
  # Accept all formats. ErrorAction should *always* work
  class_getter _accepted_formats = [] of Symbol

  abstract def default_render(error : Exception) : Lucky::Response
  abstract def report(error : Exception) : Nil

  def perform_action(error : Exception)
    # Always get the rendered error because it also includes the HTTP status.
    # We need the HTTP status to use in the debug page.
    response = render(error) || default_render(error)
    ensure_response_is_returned(response)

    if html? && Lucky::ErrorHandler.settings.show_debug_output
      response = render_exception_page(error, response.status)
    end

    response.print

    if !_dont_report.includes?(error.class)
      report(error)
    end
  end

  private def render(error : Exception) : Nil
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
    send_text_response(
      body: Lucky::ExceptionPage.for_runtime_exception(context, error).to_s,
      content_type: "text/html",
      status: status
    )
  end
end
