# These helpers check HTTP headers to determine "request type".
# Generally the `Content-Type` header is checked, followed by
# the `Accept` header, but some check other headers, such as `X-Requested-With`.
module Lucky::RequestTypeHelpers
  abstract def request_type : String
  abstract def headers : HTTP::Headers

  # Check if the request is JSON
  #
  # This tests if the request type is `application/json`
  def json? : Bool
    request_type == "application/json"
  end

  # Check if the request is AJAX
  #
  # This tests if the X-Requested-With header is `XMLHttpRequest`
  def ajax? : Bool
    headers["X-Requested-With"]? == "XMLHttpRequest"
  end

  # Check if the request is HTML
  #
  # This tests if the request type is `text/html`
  def html? : Bool
    request_type.starts_with? "text/html"
  end

  # Check if the request is XML
  #
  # This tests if the request type is `application/xml`,
  # `application/xhtml+xml`
  def xml? : Bool
    !!(request_type =~ /application\/(xhtml\+)?xml/)
  end

  # Check if the request is plain text
  #
  # This tests if the request type is `text/plain` or
  # with the optional character set per W3 RFC1341 7.1
  def plain? : Bool
    request_type == "text/plain" || request_type.downcase.starts_with?("text/plain; charset=")
  end

  private def request_type : String
    has_content_type = !(headers["Content-Type"]?.nil? || headers["Content-Type"]?.try(&.empty?))
    has_accept = !(headers["Accept"]?.nil? || headers["Accept"]?.try(&.empty?))

    return headers["Content-Type"] if has_content_type
    return headers["Accept"] if has_accept
    ""
  end

  private def headers : HTTP::Headers
    request.headers
  end
end
