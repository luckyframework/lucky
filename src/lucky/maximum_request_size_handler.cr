class Lucky::MaximumRequestSizeHandler
  include HTTP::Handler

  Habitat.create do
    setting enabled : Bool = false
    setting max_size : Int64 = 1_048_576_i64 # 1MB
  end

  def call(context)
    return call_next(context) unless settings.enabled

    body_size = 0
    body = IO::Memory.new

    begin
      buffer = Bytes.new(8192) # 8KB buffer
      while (read_bytes = context.request.body.try(&.read(buffer)))
        body_size += read_bytes
        body.write(buffer[0, read_bytes])

        if body_size > settings.max_size
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
end
