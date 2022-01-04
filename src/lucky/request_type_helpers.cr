# These helpers check HTTP headers to determine "request MIME type".
#
# Generally the `Accept` header is checked, but some check other headers, such as `X-Requested-With`.
module Lucky::RequestTypeHelpers
  private def default_format
    {% raise <<-TEXT
    Must set 'accepted_formats' or 'default_format' in #{@type} (or its parent class).

    Example of 'accepted_formats' (recommended):

      abstract class MyBaseAction < Lucky::Action
        accepted_formats [:html, :json], default: :html
      end

    Example of 'default_format' (typically used only in Errors::Show):

      class Errors::Show < Lucky::ErrorAction
        default_format :html
      end


    TEXT
    %}
  end

  # If Lucky doesn't find a format then default to the given format
  #
  # ```
  # default_format :html
  # ```
  macro default_format(format)
    private def default_format : Symbol
      {{ format }}
    end
  end

  private def clients_desired_format : Symbol
    context._clients_desired_format ||= determine_clients_desired_format
  end

  private def determine_clients_desired_format : Symbol
    Lucky::MimeType.determine_clients_desired_format(request, default_format, self.class._accepted_formats) ||
      raise Lucky::UnknownAcceptHeaderError.new(request)
  end

  # Check whether the request wants the passed in format
  def accepts?(format : Symbol) : Bool
    clients_desired_format == format
  end

  # Check if the request is JSON
  #
  # This tests if the request type is `application/json`
  def json? : Bool
    accepts?(:json)
  end

  # Check if the request is HTML
  #
  # Browsers typically send vague Accept headers. Because of that this will return `true` when:
  #
  #  * The `accepted_formats` includes `:html`
  #  * And the `Accept` header is the browser default. For example `text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
  def html? : Bool
    accepts?(:html)
  end

  # Check if the request is XML
  #
  # This tests if the request type is `application/xml`
  def xml? : Bool
    accepts?(:xml)
  end

  # Check if the request is plain text
  #
  # This tests if the `Accept` header type is `text/plain` or
  # with the optional character set per W3 RFC1341 7.1
  def plain_text? : Bool
    accepts?(:plain_text)
  end

  # Check if the request is AJAX
  #
  # This tests if the `X-Requested-With` header is `XMLHttpRequest`
  def ajax? : Bool
    request.headers["X-Requested-With"]?.try(&.downcase) == "xmlhttprequest"
  end

  # Check if the request is multipart
  #
  # This tests if the `Content-Type` header is `multipart/form-data`
  def multipart? : Bool
    !!request.headers["Content-Type"]?.try(&.downcase.starts_with?("multipart/form-data"))
  end
end
