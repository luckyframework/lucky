# Return a data for the request.
#
# `data` can be used to return contents of the IO as a file to the browser, or
# render the contents of the IO inline to a web browser. Options for the
# method:
#
# * `io` - first argument, _required_. The IO to the data from.
# * `content_type` - defaults to "application/octet-stream".
# * `disposition` - default "attachment" (downloads file), or "inline"
#   (renders file in browser).
# * `filename` - default `nil`. When overridden and paired with
#   `disposition: "attachment"` this will download file with the provided
#   filename.
# * status - `Int32` - the HTTP status code to
#   return with.
#
# Examples:
#
# ```crystal
# class Rendering::Data < Lucky::Action
#   get "/foo" do
#     data IO::Memory.new("Lucky is awesome")
#   end
# end
# ```
#
# `data` can also be used with a `String` first argument.
#
# ```crystal
# class Rendering::Data < Lucky::Action
#   get "/foo" do
#     data "Lucky is awesome"
#   end
# end
# ```
class Lucky::DataResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, io, content_type, filename, debug_message, headers

  def initialize(@context : HTTP::Server::Context,
                 @io : IO,
                 @content_type : String = "application/octet-stream",
                 @disposition : String = "attachment",
                 @filename : String? = nil,
                 @status : Int32? = nil,
                 @debug_message : String? = nil)
  end

  def print
    set_response_headers
    context.response.status_code = status
    content_length = IO.copy(io, context.response)
    context.response.content_length = content_length
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end

  private def set_response_headers : Nil
    context.response.content_type = content_type
    context.response.headers["Accept-Ranges"] = "bytes"
    context.response.headers["X-Content-Type-Options"] = "nosniff"
    context.response.headers["Content-Transfer-Encoding"] = "binary"
    context.response.headers["Content-Disposition"] = disposition
  end

  private def custom_filename? : Bool
    !!filename
  end

  def disposition : String
    if custom_filename?
      %(#{@disposition}; filename="#{filename}")
    else
      @disposition
    end
  end
end
