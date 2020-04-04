{% if !flag?(:without_zlib) %}
  require "gzip"
{% end %}

# Writes the *content_type*, *status*, and *body* to the *context* for text responses.
#
# There are two settings in `Lucky::Server.settings` that determine if
# the text response is gzip encoded; `Lucky::Server.settings.gzip_enabled` and `Lucky::Server.settings.gzip_content_types`.
# These settings can be adjusted in your Lucky app under config/server.cr
class Lucky::TextResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, content_type, body, debug_message

  def initialize(@context : HTTP::Server::Context,
                 @content_type : String,
                 @body : String | IO,
                 @status : Int32? = nil,
                 @debug_message : String? = nil)
  end

  def print : Nil
    context.response.content_type = content_type
    context.response.status_code = status
    gzip if should_gzip?
    context.response.print body
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end

  private def gzip
    context.response.headers["Content-Encoding"] = "gzip"
    context.response.output = Gzip::Writer.new(context.response.output, sync_close: true)
  end

  private def should_gzip?
    {% if !flag?(:without_zlib) %}
      Lucky::Server.settings.gzip_enabled &&
        context.request.headers.includes_word?("Accept-Encoding", "gzip") &&
        Lucky::Server.settings.gzip_content_types.includes?(content_type)
    {% end %}
  end
end
