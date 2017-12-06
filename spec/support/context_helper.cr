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

  alias Parts = Hash(String, String | Hash(String, String))

  private def build_multipart_request(form_parts : Parts = {} of String => String, file_parts : Parts = {} of String => String)
    form_io, content_type = IO::Memory.new, ""
    HTTP::FormData.build(form_io) do |formdata|
      content_type = formdata.content_type
      form_parts.each do |key, value|
        multipart_form_part(formdata, key, value)
      end
      file_parts.each do |key, value|
        multipart_file_part(formdata, key, value)
      end
    end
    build_request(method: "POST", body: form_io.to_s, content_type: content_type)
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : String)
    formdata.field(name, value)
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : Hash(String, String))
    value.each do |key, nested_value|
      nested_name = name + ":" + key
      multipart_form_part(formdata, nested_name, nested_value)
    end
  end

  private def multipart_file_part(formdata : HTTP::FormData::Builder, name : String, value : String)
    file_io = IO::Memory.new(value)
    metadata = HTTP::FormData::FileMetadata.new(filename: name)
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    formdata.file(name, file_io, metadata, headers)
  end

  private def multipart_file_part(formdata : HTTP::FormData::Builder, name : String, value : Hash(String, String))
    value.each do |key, nested_value|
      nested_name = name + ":" + key
      multipart_file_part(formdata, nested_name, nested_value)
    end
  end

  private def params
    {} of String => String
  end
end
