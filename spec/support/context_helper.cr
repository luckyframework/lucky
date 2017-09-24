module ContextHelper
  private def build_request(method = "GET", body = "", content_type = "")
    headers = HTTP::Headers.new
    headers.add("Content-Type", content_type)
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  private def build_context(path = "/", request = nil)
    io = IO::Memory.new
    request = request || HTTP::Request.new("GET", path)
    response = HTTP::Server::Response.new(io)
    HTTP::Server::Context.new request, response
  end

  private def params
    {} of String => String
  end
end
