# Return a data for the request.
#
# `data` can be used to return contents of the IO as a file to the browser, or
# render the contents of the IO inline to a web browser. Options for the
# method:
#
# * `data` - first argument, _required_. The data that should be sent.
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
# ```
# class Reports::MyReport < ApiAction
#   get "/reports/my_report" do
#     result = CSV.build do |csv|
#       csv.row "one", "two"
#       csv.row "three"
#     end

#     data result, filename: "my_report.csv"
#   end
# end
# ```
class Lucky::DataResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, data, content_type, filename, debug_message, headers

  def initialize(@context : HTTP::Server::Context,
                 @data : String,
                 @content_type : String = "application/octet-stream",
                 @disposition : String = "attachment",
                 @filename : String? = nil,
                 @status : Int32? = nil,
                 @debug_message : String? = nil)
  end

  def print
    set_response_headers
    context.response.print data
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end

  private def set_response_headers : Nil
    context.response.content_length = data.bytesize
    context.response.content_type = content_type
    context.response.status_code = status
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
