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

  private def build_multipart_request(body : Hash(String, Hash(String, String)))
    flattened_body = body.each_with_object({} of String => String) do |entry, hash|
      entry[1].each do |sub_key, sub_value|
        key_name = entry[0] + ":" + sub_key
        hash[key_name] = sub_value
      end
    end
    build_multipart_request(flattened_body)
  end

  private def build_multipart_file_request(name = "", contents = "")
    form_io, content_type = IO::Memory.new, ""
    HTTP::FormData.build(form_io) do |formdata|
      content_type = formdata.content_type
      file_io = IO::Memory.new(contents)
      metadata = HTTP::FormData::FileMetadata.new(filename: name)
      headers = HTTP::Headers{"Context-Type" => "text/plain"}
      formdata.file(name, file_io, metadata, headers)
    end
    build_request(method: "POST", body: form_io.to_s, content_type: content_type)
  end

  private def params
    {} of String => String
  end
end
