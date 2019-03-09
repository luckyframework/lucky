# These helpers check HTTP headers to determine "content type". Most check the
# Content-Type header, but some check other headers, such as `X-Requested-With`.
module Lucky::ContentTypeHelpers
  abstract def content_type : String
  abstract def headers : HTTP::Headers

  # Check if the request is JSON
  #
  # This tests if the Content-Type header is `application/json`
  def json? : Bool
    content_type == "application/json"
  end

  # Check if the request is AJAX
  #
  # This tests if the X-Requested-With header is `XMLHttpRequest`
  def ajax? : Bool
    headers["X-Requested-With"]? == "XMLHttpRequest"
  end

  # Check if the request is HTML
  #
  # This tests if the Content-Type header is `text/html`
  def html? : Bool
    content_type == "text/html"
  end

  # Check if the request is XML
  #
  # This tests if the Content-Type header is `application/xml` or
  # `application/xhtml+xml`
  def xml? : Bool
    ["application/xml", "application/xhtml+xml"].includes? content_type
  end

  # Check if the request is plain text
  #
  # This tests if the Content-Type header is `text/plain` or
  # with the optional character set per W3 RFC1341 7.1
  def plain? : Bool
    content_type == "text/plain" || content_type.downcase.starts_with?("text/plain; charset=")
  end

  private def content_type : String
    headers["Content-Type"]? || ""
  end

  private def headers : HTTP::Headers
    request.headers
  end
end
