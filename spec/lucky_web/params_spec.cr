require "../spec_helper"

include ContextHelper

describe LuckyWeb::Params do
  it "works when parsing params twice" do
    request = build_request body: "from=form",
      content_type: "application/x-www-form-urlencoded"

    params = LuckyWeb::Params.new(request)
    dup_params = LuckyWeb::Params.new(request)

    params.get(:from).should eq "form"
    dup_params.get(:from).should eq "form"
  end

  describe "all" do
    it "gives preference to body params if query param is also present" do
      request = build_request body: "from=form",
        content_type: "application/x-www-form-urlencoded"
      request.query = "from=query"

      params = LuckyWeb::Params.new(request)

      params.get(:from).should eq "form"
    end
  end

  describe "when route params are passed in" do
    it "gets the param from the route params" do
      request = build_request body: "id=from_form",
        content_type: "application/x-www-form-urlencoded"
      route_params = {"id" => "from_route"}

      params = LuckyWeb::Params.new(request, route_params)

      params.get(:id).should eq "from_route"
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

    it "parses JSON params" do
      request = build_request body: {page: 1, foo: "bar"}.to_json,
        content_type: "application/json"

      params = LuckyWeb::Params.new(request)

      params.get(:page).should eq "1"
      params.get(:foo).should eq "bar"
    end

    it "handles empty JSON body" do
      request = build_request body: "",
        content_type: "application/json"

      params = LuckyWeb::Params.new(request)

      # Should not raise
      params.get(:anything)
    end

    it "parses query params" do
      request = build_request body: "", content_type: ""
      request.query = "page=1&id=1"

      params = LuckyWeb::Params.new(request)

      params.get(:page).should eq "1"
      params.get(:id).should eq "1"
    end

    it "extracts and parses multipart params" do
      request = build_multipart_request body: "from=form"

      params = LuckyWeb::Params.new(request)
      params.get(:from).should eq "form"
    end

    it "raises if missing a param and using get! version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      expect_raises do
        params.get!(:missing)
      end
    end

    it "returns nil if using get version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.get(:missing).should be_nil
    end
  end

  describe "nested" do
    it "gets form encoded nested params" do
      request = build_request body: "user:name=paul&user:twitter_handle=@paulcsmith&something:else=1",
        content_type: "application/x-www-form-urlencoded"
      request.query = "from=query"

      params = LuckyWeb::Params.new(request)

      params.nested(:user).should eq({"name" => "paul", "twitter_handle" => "@paulcsmith"})
    end

    it "gets JSON nested params" do
      request = build_request body: {user: {name: "Paul", age: 28}}.to_json,
        content_type: "application/json"
      request.query = "from=query"

      params = LuckyWeb::Params.new(request)

      params.nested(:user).should eq({"name" => "Paul", "age" => "28"})
    end

    it "gets multipart encoded nested params" do
      request = build_multipart_request body: "user:name=paul&user:twitter_handle=@paulcsmith&something:else=1"

      params = LuckyWeb::Params.new(request)

      params.nested(:user).should eq({"name" => "paul", "twitter_handle" => "@paulcsmith"})
    end

    it "gets nested params after unescaping" do
      request = build_request body: "user%3Aname=paul",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.nested(:user).should eq({"name" => "paul"})
    end

    it "raises if nested params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      expect_raises do
        params.nested!(:missing)
      end
    end

    it "returns empty hash if nested_params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = LuckyWeb::Params.new(request)

      params.nested(:missing).should eq({} of String => String)
    end
  end
end
