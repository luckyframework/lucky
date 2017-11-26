module ContextHelper
  private def build_request(method = "GET", body = "", content_type = "")
    headers = HTTP::Headers.new
    headers.add("Content-Type", content_type)
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  private def build_context(path = "/", request = nil) : HTTP::Server::Context
    build_context_with_io(IO::Memory.new, path: path, request: request)
  end

  private def build_context_with_io(io : IO, path = "/", request = nil) : HTTP::Server::Context
    request = request || HTTP::Request.new("GET", path)
    response = HTTP::Server::Response.new(io)
    HTTP::Server::Context.new request, response
  end

  private def build_multipart_request(body = {} of String => String)
    io, content_type = IO::Memory.new, ""
    HTTP::FormData.build(io) do |formdata|
      content_type = formdata.content_type
      body.each do |key, value|
        formdata.field(key, value)
      end
    end
    build_request(method: "POST", body: io.to_s, content_type: content_type)
  end

  private def params
    {} of String => String
  end
end
