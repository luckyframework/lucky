module Lucky::ContentTypeHelpers
  abstract def content_type : String
  abstract def headers : HTTP::Headers

  def json?
    content_type == "application/json"
  end

  def ajax?
    headers["X-Requested-With"]? == "XMLHttpRequest"
  end

  def html?
    content_type == "text/html"
  end

  def xml?
    ["application/xml", "application/xhtml+xml"].includes? content_type
  end

  private def content_type : String
    headers["Content-Type"]? || ""
  end

  private def headers : HTTP::Headers
    request.headers
  end
end
