# Middleware that serves static files that have been pre-compressed.
# There can be multiple instances and the first in the middleware stack will take precedence.
# For example, if you want to serve brotli compressed assets for browsers that support it and
# serve gzip assets for those that don't you would do something like this in your middleware
# in `src/app_server.cr`:
#
# ```
# [
#   # ...
#   Lucky::StaticCompressionHandler.new("./public", file_ext: "br", content_encoding: "br"),
#   Lucky::StaticCompressionHandler.new("./public", file_ext: "gz", content_encoding: "gzip"),
#   # ...
# ]
# ```
class Lucky::StaticCompressionHandler
  include HTTP::Handler

  def initialize(@public_dir : String, @file_ext = "gz", @content_encoding = "gzip")
  end

  def call(context)
    original_path = context.request.path.to_s
    request_path = URI.decode(original_path)
    expanded_path = File.expand_path(request_path, "/")
    file_path = File.join(@public_dir, expanded_path)
    compressed_path = "#{file_path}.#{@file_ext}"
    content_type = MIME.from_filename(file_path, "application/octet-stream")

    if !should_compress?(file_path, content_type, compressed_path, context.request.headers)
      call_next(context)
      return
    end

    context.response.headers["Content-Encoding"] = @content_encoding

    last_modified = modification_time(compressed_path)
    add_cache_headers(context.response.headers, last_modified)

    if cache_request?(context, last_modified)
      context.response.status = :not_modified
      return
    end

    context.response.content_type = content_type
    context.response.content_length = File.size(compressed_path)
    File.open(compressed_path) do |file|
      IO.copy(file, context.response)
    end
  end

  private def should_compress?(file_path, content_type, compressed_path, request_headers) : Bool
    Lucky::Server.settings.gzip_enabled &&
      request_headers.includes_word?("Accept-Encoding", @content_encoding) &&
      Lucky::Server.settings.gzip_content_types.any? { |ct| content_type.starts_with?(ct) } &&
      File.exists?(compressed_path)
  end

  private def add_cache_headers(response_headers : HTTP::Headers, last_modified : Time) : Nil
    response_headers["Etag"] = etag(last_modified)
    response_headers["Last-Modified"] = HTTP.format_time(last_modified)
  end

  private def cache_request?(context : HTTP::Server::Context, last_modified : Time) : Bool
    # According to RFC 7232:
    # A recipient must ignore If-Modified-Since if the request contains an If-None-Match header field
    if if_none_match = context.request.if_none_match
      match = {"*", context.response.headers["Etag"]}
      if_none_match.any? { |etag| match.includes?(etag) }
    elsif if_modified_since = context.request.headers["If-Modified-Since"]?
      header_time = HTTP.parse_time(if_modified_since)
      # File mtime probably has a higher resolution than the header value.
      # An exact comparison might be slightly off, so we add 1s padding.
      # Static files should generally not be modified in subsecond intervals, so this is perfectly safe.
      # This might be replaced by a more sophisticated time comparison when it becomes available.
      !!(header_time && last_modified <= header_time + 1.second)
    else
      false
    end
  end

  private def etag(modification_time)
    %{W/"#{modification_time.to_unix}"}
  end

  private def modification_time(file_path)
    File.info(file_path).modification_time
  end
end
