# :nodoc:
class Lucky::FormDataParser
  getter body : String
  getter request : HTTP::Request

  def initialize(@body, @request)
  end

  def form_data : Lucky::FormData
    body_io = IO::Memory.new(body)
    form_data = Lucky::FormData.new
    boundary = MIME::Multipart.parse_boundary(request.headers["Content-Type"]).to_s

    HTTP::FormData.parse(body_io, boundary) do |part|
      form_data.add(part)
    end
    form_data
  end
end
