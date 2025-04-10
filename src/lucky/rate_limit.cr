# Adds in action level rate limiting. Limit the request rate of a specific
# action by including this module, then define the `rate_limit` method to configue.
# For convienence, you can also use the `rate_limit` macro.
#
# ```
# class Reports::Index < ApiAction
#   include Lucky::RateLimit
#   rate_limit to: 5, within: 1.minute
#
#   get "/reports"
#     plain_text "ok"
#   end
# end
# ```
#
# By default, the `rate_limit_identifier` uses the IP address. You can override this method
# to define a different strategy.
module Lucky::RateLimit
  macro included
    before enforce_rate_limit
  end

  # Defines the rate limit limiting to `to` requests within `within` time span.
  # ```
  # def rate_limit : NamedTuple(to: Int32, within: Time::Span)
  #   {to: 5, within: 1.minute}
  # end
  # ```
  abstract def rate_limit : NamedTuple(to: Int32, within: Time::Span)

  # Convience macro to define the required `rate_limit` method
  # ```
  # rate_limit to: 5, within: 1.minute
  # ```
  macro rate_limit(to, within)
    def rate_limit : NamedTuple(to: Int32, within: Time::Span)
      {to: {{to}}, within: {{within}}}
    end
  end

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
    klass = {{ @type.stringify.downcase.gsub(/::/, ":") }}
    "ratelimit:#{klass}:#{rate_limit_identifier}"
  end

  private def rate_limit_identifier : String
    context.request.remote_ip.presence || raise Lucky::MissingRateLimitIdentifier.new("The rate limit identifier was not found. Override the `rate_limit_identifier` method or ensure the IP address exists.")
  end
end
