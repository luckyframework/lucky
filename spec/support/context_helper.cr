module ContextHelper
  private def build_request(method = "GET", body = "", content_type = "")
    headers = HTTP::Headers.new
    headers.add("Content-Type", content_type)
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  private def build_context(path = "/", request = nil) : HTTP::Server::Context
    build_context_with_io(IO::Memory.new, path: path, request: request)
  end

  private def build_context(method : String) : HTTP::Server::Context
    build_context_with_io(
      IO::Memory.new,
      path: "/",
      request: build_request(method)
    )
  end

  private def build_context_with_io(io : IO, path = "/", request = nil) : HTTP::Server::Context
    request = request || HTTP::Request.new("GET", path)
    response = HTTP::Server::Response.new(io)
    HTTP::Server::Context.new request, response
  end

  private def build_context_with_flash(flash : String)
    build_context.tap do |context|
      context.session[Lucky::Flash::Handler::PARAM_KEY] = flash
    end
  end

  private def params
    {} of String => String
  end
end
