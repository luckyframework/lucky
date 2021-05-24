# Return a file's contents for the request.
#
# `file` can be used to return a file and it's contents to the browser, or
# render the contents of the file inline to a web browser. Options for the
# method:
#
# * `path` - first argument, _required_. The path to the file.
# * `content_type` - defaults to the mime-type that corresponds to the file's
#   extension.
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
# ```
# class Rendering::File < Lucky::Action
#   get "/file" do
#     file "spec/fixtures/lucky_logo.png"
#   end
# end
# ```
#
# For a plain text file with no extension, have it downloaded with the file
# named "custom.html" and the content_type "text/html":
#
# ```
# class Rendering::File::CustomContentType < Lucky::Action
#   get "/foo" do
#     file "spec/fixtures/plain_text",
#       disposition: "attachment",
#       filename: "custom.html",
#       content_type: "text/html"
#   end
# end
# ```
class Lucky::FileResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, path, filename, debug_message, headers

  def initialize(@context : HTTP::Server::Context,
                 @path : String,
                 @content_type : String? = nil,
                 @disposition : String = "attachment",
                 @filename : String? = nil,
                 @status : Int32? = nil,
                 @debug_message : String? = nil)
  end

  def print
    raise Lucky::MissingFileError.new(path) unless file_exists?

    set_response_headers
    context.response.status_code = status
    File.open(full_path) { |file| IO.copy(file, context.response) }
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end

  private def set_response_headers : Nil
    context.response.content_length = File.size(full_path)
    context.response.content_type = content_type
    context.response.headers["Accept-Ranges"] = "bytes"
    context.response.headers["X-Content-Type-Options"] = "nosniff"
    context.response.headers["Content-Transfer-Encoding"] = "binary"
    context.response.headers["Content-Disposition"] = disposition
  end

  private def custom_filename? : Bool
    !!filename
  end

  def content_type
    @content_type || content_type_from_file
  end

  def disposition : String
    if custom_filename?
      %(#{@disposition}; filename="#{filename}")
    else
      @disposition
    end
  end

  private def content_type_from_file : String
    extension = File.extname(path)

    {
      ".css"   => "text/css",
      ".gif"   => "image/gif",
      ".htm"   => "text/html",
      ".html"  => "text/html",
      ".ico"   => "image/x-icon",
      ".jpg"   => "image/jpeg",
      ".jpeg"  => "image/jpeg",
      ".js"    => "application/javascript",
      ".json"  => "application/json",
      ".mp4"   => "video/mp4",
      ".otf"   => "application/font-sfnt",
      ".ttf"   => "application/font-sfnt",
      ".png"   => "image/png",
      ".svg"   => "image/svg+xml",
      ".txt"   => "text/plain",
      ".webm"  => "video/webm",
      ".woff"  => "application/font-woff",
      ".woff2" => "font/woff2",
      ".xml"   => "application/xml",
      ""       => "application/octet-stream",
    }[extension]
  end

  private def full_path : String
    File.expand_path(path, Dir.current)
  end

  private def file_exists? : Bool
    File.file?(full_path) && File.readable?(full_path)
  end
end
