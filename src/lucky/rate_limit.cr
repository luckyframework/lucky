module Lucky::RateLimit
  macro included
    before enforce_rate_limit
  end

  abstract def rate_limit : NamedTuple(to: Int32, within: Time::Span)

  private def enforce_rate_limit
    cache = LuckyCache.settings.storage
    count = cache.fetch(rate_limit_key, as: Int32, expires_in: rate_limit["within"]) { 0 }
    cache.write(rate_limit_key, expires_in: rate_limit["within"]) { count + 1 }

    if count > rate_limit["to"]
      context.response.status = HTTP::Status::TOO_MANY_REQUESTS
      context.response.headers["Retry-After"] = rate_limit["within"].to_s
      plain_text("Rate limit exceeded")
    else
      continue
    end
  end

  private def rate_limit_key : String
    klass = self.class.to_s.downcase.gsub("::", ":")
    "ratelimit:#{klass}:#{rate_limit_identifier}"
  end

  private def rate_limit_identifier : Socket::Address | Nil
    request = context.request

    if x_forwarded = request.headers["X_FORWARDED_FOR"]?.try(&.split(',').first?).presence
      begin
        Socket::IPAddress.new(x_forwarded, 0)
      rescue Socket::Error
        # if the x_forwarded is not a valid ip address we fallback to request.remote_address
        request.remote_address
      end
    else
      request.remote_address
    end
  end
end
