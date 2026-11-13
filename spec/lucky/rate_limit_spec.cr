require "../spec_helper"

include ContextHelper

class RateLimitRoutes::Index < TestAction
  include Lucky::RateLimit

  get "/rate_limit" do
    plain_text "hello"
  end

  def rate_limit : NamedTuple(to: Int32, within: Time::Span)
    {to: 1, within: 1.minute}
  end

  private def rate_limit_identifier : String
    "test-key"
  end
end

class RateLimitRoutesWithMacro::Index < TestAction
  include Lucky::RateLimit
  rate_limit to: 1, within: 1.minute

  get "/rate_limit_2" do
    plain_text "hello"
  end

  private def rate_limit_identifier : String
    "test-key"
  end
end

class RateLimitRoutesWithBoundary::Index < TestAction
  include Lucky::RateLimit
  rate_limit to: 2, within: 1.minute

  get "/rate_limit_3" do
    plain_text "hello"
  end

  private def rate_limit_identifier : String
    "test-key"
  end
end

describe Lucky::RateLimit do
  describe "RateLimit" do
    it "when request count is less than the rate limit" do
      with_memory_store do
        headers = HTTP::Headers.new
        headers["X_FORWARDED_FOR"] = "127.0.0.1"
        request = HTTP::Request.new("GET", "/rate_limit", body: "", headers: headers)
        context = build_context(request)

        route = RateLimitRoutes::Index.new(context, params).call
        route.context.response.status.should eq(HTTP::Status::OK)
      end
    end

    it "when request count is over the rate limit" do
      with_memory_store do
        headers = HTTP::Headers.new
        headers["X_FORWARDED_FOR"] = "127.0.0.1"
        request = HTTP::Request.new("GET", "/rate_limit_2", body: "", headers: headers)
        context = build_context(request)

        10.times do
          RateLimitRoutesWithMacro::Index.new(context, params).call
        end

        route = RateLimitRoutesWithMacro::Index.new(context, params).call
        route.context.response.status.should eq(HTTP::Status::TOO_MANY_REQUESTS)
      end
    end

    it "allows exactly the configured number of requests" do
      with_memory_store do
        request = HTTP::Request.new("GET", "/rate_limit_3", body: "", headers: HTTP::Headers.new)
        context = build_context(request)

        2.times do
          route = RateLimitRoutesWithBoundary::Index.new(context, params).call
          route.context.response.status.should eq(HTTP::Status::OK)
        end

        route = RateLimitRoutesWithBoundary::Index.new(context, params).call
        route.context.response.status.should eq(HTTP::Status::TOO_MANY_REQUESTS)
      end
    end

    it "sets Retry-After in number of seconds" do
      with_memory_store do
        request = HTTP::Request.new("GET", "/rate_limit_3", body: "", headers: HTTP::Headers.new)
        context = build_context(request)

        3.times do
          RateLimitRoutesWithBoundary::Index.new(context, params).call
        end

        context.response.headers["Retry-After"].should eq("60")
      end
    end
  end
end

private def with_memory_store(&)
  LuckyCache.temp_config(storage: LuckyCache::MemoryStore.new) do
    yield
  end
end
