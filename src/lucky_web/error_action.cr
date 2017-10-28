require "./*"

abstract class LuckyWeb::ErrorAction
  include LuckyWeb::ActionDelegates
  include LuckyWeb::Renderable
  include LuckyWeb::Redirectable

  getter context

  def initialize(@context : HTTP::Server::Context)
  end

  abstract def handle_error(error : Exception) : LuckyWeb::Response

  def perform_action(error : Exception)
    response = handle_error(error)
    ensure_response_is_returned(response)
    response.print
  end

  private def ensure_response_is_returned(response : LuckyWeb::Response) : LuckyWeb::Response
    response
  end

  private def ensure_response_is_returned(response)
    {% raise <<-ERROR
      You must return a LuckyWeb::Response from handle_error. You can do that by using
      head, render, redirect, json, render_text, etc.

      Example:
        def handle_error(error : Exception)
          # Returns a LuckyWeb::Response
          # Could also be render, json, render_text, etc.
          head status: 500
        end
      ERROR %}
  end
end
