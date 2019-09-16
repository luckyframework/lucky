require "./*"

abstract class Lucky::ErrorAction
  include Lucky::ActionDelegates
  include Lucky::Renderable
  include Lucky::Redirectable
  include Lucky::RequestTypeHelpers
  include Lucky::Exposable

  getter context

  def initialize(@context : HTTP::Server::Context)
  end

  # :nodoc:
  # Accept all formats. ErrorAction should *always* work
  class_getter _accepted_formats = [] of Symbol

  abstract def render(error : Exception) : Lucky::Response

  def perform_action(error : Exception)
    response = render(error)
    ensure_response_is_returned(response)
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
end
