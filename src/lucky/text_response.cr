{% if !flag?(:without_zlib) %}
  require "gzip"
{% end %}

class Lucky::TextResponse < Lucky::Response
  Habitat.create do
    setting gzip_enabled : Bool = false
    setting gzip_content_types : Array(String) = %w(text/html text/javascript application/json text/plain application/xml text/csv)
  end

  DEFAULT_STATUS = 200

  getter context, content_type, body, debug_message

  def initialize(@context : HTTP::Server::Context,
                 @content_type : String,
                 @body : String,
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
      settings.gzip_enabled &&
        context.request.headers.includes_word?("Accept-Encoding", "gzip") &&
        settings.gzip_content_types.includes?(content_type)
    {% end %}
  end
end
