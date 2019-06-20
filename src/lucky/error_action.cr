require "./*"

abstract class Lucky::ErrorAction
  include Lucky::ActionDelegates
  include Lucky::Renderable
  include Lucky::Redirectable
  include Lucky::RequestTypeHelpers
  include Lucky::Exposeable

  getter context

  def initialize(@context : HTTP::Server::Context)
  end

  abstract def handle_error(error : Exception) : Lucky::Response

  def perform_action(error : Exception)
    response = handle_error(error)
    ensure_response_is_returned(response)
    response.print
  end

  private def ensure_response_is_returned(response : Lucky::Response) : Lucky::Response
    response
  end

  private def ensure_response_is_returned(response)
    {% raise <<-ERROR
      You must return a Lucky::Response from handle_error. You can do that by using
      head, render, redirect, json, text, etc.

      Example:
        def handle_error(error : Exception)
          # Returns a Lucky::Response
          # Could also be render, json, text, etc.
          head status: 500
        end
      ERROR
    %}
  end
end
