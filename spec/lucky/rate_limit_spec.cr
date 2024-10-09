require "../spec_helper"

include ContextHelper

class RateLimitRoutes::Index < TestAction
  include Lucky::RateLimit

  get "/rate_limit" do
    plain_text "hello"
  end

  private def rate_limit : NamedTuple(to: Int32, within: Time::Span)
    {to: 1, within: 1.minute}
  end
end

describe Lucky::RateLimit do
  describe "RateLimit" do
    it "when request count is less than the rate limit" do
      headers = HTTP::Headers.new
      headers["X_FORWARDED_FOR"] = "127.0.0.1"
      request = HTTP::Request.new("GET", "/rate_limit", body: "", headers: headers)
      context = build_context(request)

      route = RateLimitRoutes::Index.new(context, params).call
      route.context.response.status.should eq(HTTP::Status::OK)
    end

    it "when request count is over the rate limit" do
      headers = HTTP::Headers.new
      headers["X_FORWARDED_FOR"] = "127.0.0.1"
      request = HTTP::Request.new("GET", "/rate_limit", body: "", headers: headers)
      context = build_context(request)

      10.times do
        RateLimitRoutes::Index.new(context, params).call
      end

      route = RateLimitRoutes::Index.new(context, params).call
      route.context.response.status.should eq(HTTP::Status::TOO_MANY_REQUESTS)
    end
  end
end
