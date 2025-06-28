require "../spec_helper"

describe "Lucky HTTP/2 Integration" do
  describe "configuration" do
    it "has http2_enabled setting" do
      Lucky::Server.settings.http2_enabled.should be_false
    end
  end

  describe "routing" do
    it "can define HTTP/2 routes with the http2 macro" do
      # The http2 macro should add routes to the HTTP/2 matcher
      http2 :get, "/api/v2/users", TestHTTP2APIAction

      # Find the route
      match = Lucky.router.find_http2_action(:get, "/api/v2/users")
      match.should_not be_nil
      match.not_nil!.payload.should eq(TestHTTP2APIAction)
    end

    it "keeps HTTP/2 routes separate from regular routes" do
      # Add a regular route
      Lucky.router.add(:get, "/api/v1/users", TestAPIAction)

      # Add an HTTP/2 route with the same path
      http2 :get, "/api/v1/users", TestHTTP2APIAction

      # They should be found separately
      regular_match = Lucky.router.find_action(:get, "/api/v1/users")
      http2_match = Lucky.router.find_http2_action(:get, "/api/v1/users")

      regular_match.should_not be_nil
      http2_match.should_not be_nil

      regular_match.not_nil!.payload.should eq(TestAPIAction)
      http2_match.not_nil!.payload.should eq(TestHTTP2APIAction)
    end

    it "supports route parameters in HTTP/2 routes" do
      http2 :get, "/api/v2/users/:id/posts/:post_id", TestHTTP2APIAction

      match = Lucky.router.find_http2_action(:get, "/api/v2/users/123/posts/456")
      match.should_not be_nil
      match.not_nil!.params["id"].should eq("123")
      match.not_nil!.params["post_id"].should eq("456")
    end
  end
end

# Test actions
class TestAPIAction < Lucky::Action
  accepted_formats [:json]

  def call
    json({status: "ok"})
  end
end

class TestHTTP2APIAction < Lucky::HTTP2::Action
  def call
    # In a real implementation, this would use HTTP/2 specific features
    # For now, just a placeholder
  end
end
