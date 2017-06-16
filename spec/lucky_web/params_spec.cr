require "../spec_helper"

describe LuckyWeb::Params do
  describe "all" do
    it "gives preference to body params if query param is also present" do
      request = build_request body: "from=form",
        content_type: "application/x-www-form-urlencoded"
      request.query = "from=query"

      params = LuckyWeb::Params.new(request)

      params.get(:from).should eq "form"
    end
  end

  describe "get" do
    it "parses form encoded params" do
      request = build_request body: "page=1&foo=bar",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.get(:page).should eq "1"
      params.get(:foo).should eq "bar"
    end

    it "parses query params" do
      request = build_request body: "", content_type: ""
      request.query = "page=1&id=1"

      params = LuckyWeb::Params.new(request)

      params.get(:page).should eq "1"
      params.get(:id).should eq "1"
    end

    it "raises if missing a param and using get! version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      expect_raises do
        params.get(:missing)
      end
    end

    it "returns nil if using get? version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.get?(:missing).should be_nil
    end
  end

  describe "nested_in" do
    it "gets nested params" do
      request = build_request body: "user:name=paul&user:twitter_handle=@paulcsmith&something:else=1",
        content_type: "application/x-www-form-urlencoded"
      request.query = "from=query"

      params = LuckyWeb::Params.new(request)

      params.nested_in(:user).should eq({"name" => "paul", "twitter_handle" => "@paulcsmith"})
    end

    it "raises if no nested params exist" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      expect_raises do
        params.nested_in(:missing)
      end
    end

    it "returns empty hash if no nested_params exist" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.nested_in?(:missing).should eq({} of String => String)
    end
  end
end

private def build_request(body, content_type)
  headers = HTTP::Headers.new
  headers.add("Content-Type", content_type)
  HTTP::Request.new("GET", "/", body: body, headers: headers)
end
