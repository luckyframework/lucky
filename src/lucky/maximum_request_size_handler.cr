# Allows a maximum request size to be set for incoming requests.
#
# Configure the max_size to the maximum size in bytes that you
# want to allow.
#
# ```
# Lucky::MaximumRequestSizeHandler.configure do |settings|
#   settings.enabled = true
#   settings.max_size = 1_048_576 # 1MB
# end
# ```

class Lucky::MaximumRequestSizeHandler
  include HTTP::Handler

  Habitat.create do
    setting enabled : Bool = false
    setting max_size : Int64 = 1_048_576_i64 # 1MB
  end

  def call(context : HTTP::Server::Context)
    return call_next(context) unless settings.enabled

    max_size = request_limit_for(context)

    body_size = 0_i64
    body = IO::Memory.new

    begin
      buffer = Bytes.new(8192) # 8KB buffer
      while read_bytes = context.request.body.try(&.read(buffer))
        body_size += read_bytes
        body.write(buffer[0, read_bytes])

        if body_size > max_size
          context.response.status = HTTP::Status::PAYLOAD_TOO_LARGE
          context.response.print("Request entity too large")
          return context
        end

        break if read_bytes < buffer.size # End of body
      end
    rescue IO::Error
      context.response.status = HTTP::Status::BAD_REQUEST
      context.response.print("Error reading request body")
      return context
    end

    # Reset the request body for downstream handlers
    context.request.body = IO::Memory.new(body.to_s)

    call_next(context)
  end

  private def request_limit_for(context : HTTP::Server::Context) : Int64
    matched_action_limit(context) || settings.max_size
  end

  private def matched_action_limit(context : HTTP::Server::Context) : Int64?
    find_matching_action(context).try do |match|
      action_class = match.payload
      if action_class.responds_to?(:request_body_limit)
        action_class.request_body_limit
      end
    end
  end

  private def find_matching_action(context : HTTP::Server::Context)
    Lucky.router.find_action(routing_request(context))
  end

  private def routing_request(context : HTTP::Server::Context) : HTTP::Request
    original_path = context.request.path
    if Lucky::MimeType.extract_format_from_path(original_path)
      path_without_format = original_path.sub(/^([^?]*)\.[a-zA-Z0-9]+(\?.*)?$/, "\\1\\2")
      modified_request = context.request.dup
      modified_request.path = path_without_format
      modified_request
    else
      context.request
    end
  end
end
