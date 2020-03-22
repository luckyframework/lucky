# Sets the HTTP::Request#remote_address value
# to the value of the first IP in the `X-Forwarded-For`
# header, or fallback to the default `remote_address`.
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For
#
# This Handler does a best guess for the IP which is generally good
# enough. If you require IP based Authentication, then you may want
# to handle this on your own as there will be edge cases when related
# to mobile clients on the go, and potential IP spoofing attacks.
class Lucky::RemoteIpHandler
  include HTTP::Handler

  def call(context)
    context.request.remote_address = fetch_remote_ip(context)
    call_next(context)
  end

  private def fetch_remote_ip(context : HTTP::Server::Context) : String?
    request = context.request

    x_forwarded = request.headers["X_FORWARDED_FOR"]?.try(&.split(',').first?)
    x_forwarded.blank? ? request.remote_address : x_forwarded
  end
end
