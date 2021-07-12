module ContextHelper
  extend self

  private def build_request(
    method = "GET",
    body = "",
    content_type = "",
    fixed_length : Bool = false,
    host = "example.com"
  ) : HTTP::Request
    headers = HTTP::Headers.new
    headers.add("Content-Type", content_type)
    headers.add("Host", host)
    if fixed_length
      body = HTTP::FixedLengthContent.new(IO::Memory.new(body), body.size)
    end
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  def build_context(
    path = "/",
    request : HTTP::Request? = nil
  ) : HTTP::Server::Context
    build_context_with_io(IO::Memory.new, path: path, request: request)
  end

  def build_context(request : HTTP::Request) : HTTP::Server::Context
    build_context(path: "/", request: request)
  end

  private def build_context(method : String) : HTTP::Server::Context
    build_context_with_io(
      IO::Memory.new,
      path: "/",
      request: build_request(method)
    )
  end

  private def build_context_with_io(
    io : IO,
    path = "/",
    request = nil
  ) : HTTP::Server::Context
    request = request || HTTP::Request.new("GET", path)
    response = HTTP::Server::Response.new(io)
    HTTP::Server::Context.new request, response
  end

  private def build_context_with_flash(flash : String)
    build_context.tap do |context|
      context.session.set(Lucky::FlashStore::SESSION_KEY, flash)
    end
  end

  private def params
    {} of String => String
  end
end
