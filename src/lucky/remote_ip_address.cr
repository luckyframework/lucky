module Lucky::RemoteIpAddress
  # Returns a `String` IP Address of the remote client by
  # looking at a few different possible options.
  #
  # * HTTP_X_FORWARDED_FOR header
  # * REMOTE_ADDRESS header
  # * Fallback to localhost 127.0.0.1
  def remote_ip : String
    request = @context.request

    request.headers["HTTP_X_FORWARDED_FOR"]?.try(&.split(',').first) ||
      request.remote_address ||
      "127.0.0.1"
  end
end
