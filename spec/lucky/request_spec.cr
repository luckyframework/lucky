require "../../spec_helper"

describe Lucky::Request do
  describe "#get" do
    it "sends requests to correct uri" do
      path = "/any_path"
      uri = Lucky::RouteHelper.settings.base_uri + path
      request = Lucky::Request.new

      request.get(path)
      request.url.should eq uri
    end
  end

  describe "authenticates" do
    it "authenticates users with authorization token" do
      test_user = TestUser.new
      request = Lucky::Request.new

      request.get("/", as: test_user)
      request.headers["Authorization"].should eq test_user.generate_token
    end
  end

  describe "#post" do
    it "parses body into query params" do
      request = Lucky::Request.new
      request.post("/", {"first" => "value", "second" => "value"})
      request.query_params.should eq "first=value&second=value"
    end
  end

  describe "#put" do
    it "parses body into query params" do
      request = Lucky::Request.new
      request.put("/", {"first" => "value", "second" => "value"})
      request.query_params.should eq "first=value&second=value"
    end
  end
end

class TestUser
  def generate_token
    "test_token"
  end
end
