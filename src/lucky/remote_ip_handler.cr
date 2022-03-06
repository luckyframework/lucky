# Sets the HTTP::Request#remote_address value as `Socket::IPAddress?`
# to the value of the last IP in the `X-Forwarded-For`
# header, or fallback to the default `remote_address`.
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For
#
# This will also set a `remote_ip` String value as `String` which will be
# either the raw `remote_address` value, or an empty string.
#
# This Handler does a "best guess" for the IP which is generally good
# enough. If you require IP based Authentication, then you may want
# to handle this on your own as there will be edge cases when related
# to mobile clients on the go, and potential IP spoofing attacks.
# More detailed info: https://adam-p.ca/blog/2022/03/x-forwarded-for/
class Lucky::RemoteIpHandler
  include HTTP::Handler

  Habitat.create do
    setting ip_header_name : String = "X-Forwarded-For"
  end

  def call(context)
    context.request.remote_address = fetch_remote_ip(context)
    if ip_value = context.request.remote_address.as?(Socket::IPAddress).try(&.address.presence)
      context.request.remote_ip = ip_value
    end
    call_next(context)
  end

  private def fetch_remote_ip(context : HTTP::Server::Context) : Socket::Address?
    request = context.request
    header = settings.ip_header_name
    remote_ip = request.headers[header]?.try(&.split(',').last?).presence

    if remote_ip
      begin
        Socket::IPAddress.new(remote_ip.to_s, 0)
      rescue Socket::Error
        # if the x_forwarded is not a valid ip address we fallback to request.remote_address
        request.remote_address
      end
    else
      request.remote_address
    end
  end
end
