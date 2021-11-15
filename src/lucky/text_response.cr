{% if !flag?(:without_zlib) %}
  require "compress/gzip"
{% end %}

# Writes the *content_type*, *status*, and *body* to the *context* for text responses.
#
# There are two settings in `Lucky::Server.settings` that determine if
# the text response is gzip encoded; `Lucky::Server.settings.gzip_enabled` and `Lucky::Server.settings.gzip_content_types`.
# These settings can be adjusted in your Lucky app under config/server.cr
class Lucky::TextResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, content_type, body, debug_message, enable_cookies

  def initialize(@context : HTTP::Server::Context,
                 @content_type : String,
                 @body : String | IO,
                 @status : Int32? = nil,
                 @debug_message : String? = nil,
                 @enable_cookies : Bool = true)
  end

  def print : Nil
    if enable_cookies
      write_flash
      write_session
      write_cookies
    end
    context.response.content_type = content_type
    context.response.status_code = status
    gzip if should_gzip?
    context.response.print(body) if should_print?
  rescue e : IO::Error
    Lucky::Log.error(exception: e) { "Broken Pipe: Maybe the client navigated away?" }
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end

  private def gzip
    context.response.headers["Content-Encoding"] = "gzip"
    context.response.output = Compress::Gzip::Writer.new(context.response.output, sync_close: true)
  end

  private def should_gzip?
    {% if !flag?(:without_zlib) %}
      Lucky::Server.settings.gzip_enabled &&
        context.request.headers.includes_word?("Accept-Encoding", "gzip") &&
        Lucky::Server.settings.gzip_content_types.includes?(content_type)
    {% end %}
  end

  private def should_print? : Bool
    context.request.method.downcase != "head"
  end

  private def write_flash : Nil
    context.session.set(
      Lucky::FlashStore::SESSION_KEY,
      context.flash.to_json
    )
  end

  private def write_session : Nil
    context.cookies.set(
      Lucky::Session.settings.key,
      context.session.to_json
    )
  end

  private def write_cookies : Nil
    response = context.response

    context.cookies.updated.each do |cookie|
      response.cookies[cookie.name] = cookie
    end

    response.cookies.add_response_headers(response.headers)
  end
end
