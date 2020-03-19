require "../spec_helper"

include ContextHelper
include MultipartHelper

describe Lucky::Params do
  describe "#query" do
    it "returns the HTTP::Params for the query params" do
      request = build_request
      request.query = "q=test"

      params = Lucky::Params.new(request)

      params.query.should be_a(HTTP::Params)
      params.query["q"].should eq("test")
    end
  end

  describe "#json" do
    it "returns a JSON::Any object" do
      request = build_request(body: {page: 1}.to_json)

      params = Lucky::Params.new(request)

      params.json.should be_a(JSON::Any)
      params.json["page"].as_i.should eq(1)
    end
  end

  it "works when parsing params twice" do
    request = build_request body: "from=form",
      content_type: "application/x-www-form-urlencoded"

    params = Lucky::Params.new(request)
    dup_params = Lucky::Params.new(request)

    params.get?(:from).should eq "form"
    dup_params.get?(:from).should eq "form"
  end

  it "works when parsing multipart params twice" do
    request = build_multipart_request form_parts: {
      "user" => {
        "name" => "Paul",
        "age"  => "28",
      },
    }

    params = Lucky::Params.new(request)
    dup_params = Lucky::Params.new(request)

    params.nested?(:user)
    dup_params.nested?(:user)
  end

  describe "all" do
    it "gives preference to body params if query param is also present" do
      request = build_request body: "from=form",
        content_type: "application/x-www-form-urlencoded"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.get?(:from).should eq "form"
    end

    it "raises an exception if parsing fails" do
      invalid_json = "//"
      request = build_request body: invalid_json,
        content_type: "application/json"

      params = Lucky::Params.new(request)

      expect_raises Lucky::ParamParsingError do
        params.get?(:page).should eq "1"
      end
    end
  end

  describe "when route params are passed in" do
    it "gets the param from the route params" do
      request = build_request body: "id=from_form",
        content_type: "application/x-www-form-urlencoded"
      route_params = {"id" => "from_route"}

      params = Lucky::Params.new(request, route_params)

      params.get?(:id).should eq "from_route"
    end
  end

  describe "get" do
    it "parses form encoded params" do
      request = build_request body: "page=1&foo=bar",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get?(:page).should eq "1"
      params.get?(:foo).should eq "bar"
    end

    it "parses JSON params" do
      request = build_request body: {page: 1, foo: "bar"}.to_json,
        content_type: "application/json"

      params = Lucky::Params.new(request)

      params.get?(:page).should eq "1"
      params.get?(:foo).should eq "bar"
    end

    it "handles empty JSON body" do
      request = build_request body: "",
        content_type: "application/json"

      params = Lucky::Params.new(request)

      # Should not raise
      params.get?(:anything)
    end

    it "handles JSON with charset directive in Content-Type header" do
      request = build_request body: {page: 1, foo: "bar"}.to_json,
        content_type: "application/json;charset=UTF-8"

      params = Lucky::Params.new(request)

      params.get?(:page).should eq "1"
      params.get?(:foo).should eq "bar"
    end

    it "parses query params" do
      request = build_request body: "", content_type: ""
      request.query = "page=1&id=1"

      params = Lucky::Params.new(request)

      params.get?(:page).should eq "1"
      params.get?(:id).should eq "1"
    end

    it "parses params in multipart requests" do
      request = build_multipart_request form_parts: {"from" => "multipart"}

      params = Lucky::Params.new(request)

      params.get(:from).should eq "multipart"
    end

    it "raises if missing a param and using get! version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get(:missing)
      end
    end

    it "returns nil if using get version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get?(:missing).should be_nil
    end
  end

  describe "nested" do
    it "gets nested form encoded params" do
      request = build_request body: "user:name=paul&user:twitter_handle=@paulcsmith&something:else=1",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "paul", "twitter_handle" => "@paulcsmith"})
    end

    it "gets nested JSON params" do
      request = build_request body: {user: {name: "Paul", age: 28}}.to_json,
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "Paul", "age" => "28"})
    end

    it "gets empty JSON params when nested key is missing" do
      request = build_request body: "{}",
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({} of String => JSON::Any)
    end

    it "handles JSON with charset directive in Content-Type header" do
      request = build_request body: {user: {name: "Paul", age: 28}}.to_json,
        content_type: "application/json; charset=UTF-8"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "Paul", "age" => "28"})
    end

    it "gets nested JSON params mixed with query params" do
      request = build_request body: {user: {name: "Bunyan", age: 102}}.to_json,
        content_type: "application/json"
      request.query = "user:active=true"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "Bunyan", "age" => "102", "active" => "true"})
    end

    it "gets nested multipart params" do
      request = build_multipart_request form_parts: {
        "user" => {
          "name" => "Paul",
          "age"  => "28",
        },
      }

      params = Lucky::Params.new(request)

      params.nested(:user).should eq({"name" => "Paul", "age" => "28"})
    end

    it "gets nested query params" do
      request = build_request body: "filter:toppings=left_beef&filter:type=none", content_type: ""
      request.query = "filter:query=pizza&sort=desc"
      params = Lucky::Params.new(request)
      params.nested?("filter").should eq({"type" => "none", "query" => "pizza", "toppings" => "left_beef"})
    end

    it "returns an empty hash when no nested is found" do
      request = build_request body: "", content_type: ""
      request.query = "a=1"
      params = Lucky::Params.new(request)
      params.nested?("a").empty?.should eq true
    end

    it "gets nested params after unescaping" do
      request = build_request body: "user%3Aname=paul",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "paul"})
    end

    it "raises if nested params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingNestedParamError do
        params.nested(:missing)
      end
    end

    it "returns empty hash if nested_params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested?(:missing).should eq({} of String => String)
    end
  end

  describe "get_file" do
    it "gets files" do
      request = build_multipart_request file_parts: {
        "welcome_file" => "welcome file contents",
      }

      params = Lucky::Params.new(request)

      file = params.get_file(:welcome_file)
      file.is_a?(Lucky::UploadedFile).should eq(true)
      File.read(file.path).should eq "welcome file contents"
    end

    it "gets files alongside params" do
      request = build_multipart_request(
        form_parts: {
          "from" => "multipart",
        },
        file_parts: {
          "with" => "a file",
        }
      )

      params = Lucky::Params.new(request)

      file = params.get_file(:with)
      File.read(file.path).should eq "a file"
    end

    it "raises if missing a param and using get_file version" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get_file(:missing)
      end
    end

    it "returns nil if using get_file? version" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      params.get_file?(:missing).should be_nil
    end
  end

  describe "nested_file" do
    it "gets multipart nested params" do
      request = build_multipart_request file_parts: {
        "user" => {
          "avatar_file" => "binary_image_content",
        },
      }

      params = Lucky::Params.new(request)

      file = params.nested_file(:user)["avatar_file"]
      File.read(file.path).should eq "binary_image_content"
    end

    it "raises if nested files are missing and using nested_file! version" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingNestedParamError do
        params.nested_file(:missing)
      end
    end

    it "returns empty hash if nested files are missing and using nested_file? version" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      params.nested_file?(:missing).should eq({} of String => File)
    end
  end

  describe "many_nested" do
    it "gets nested form encoded params" do
      request = build_request body: "users[0]:name=paul&users[1]:twitter_handle=@paulamason&users[0]:twitter_handle=@paulsmith&users[1]:name=paula&something:else=1",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([
        {"name" => "paul", "twitter_handle" => "@paulsmith"},
        {"twitter_handle" => "@paulamason", "name" => "paula"},
      ])
    end

    it "gets nested JSON params" do
      request = build_request(
        body: {
          users: [
            {name: "Paul", age: 28},
            {name: "Paula", age: 43},
          ],
        }.to_json,
        content_type: "application/json"
      )
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([
        {"name" => "Paul", "age" => "28"},
        {"name" => "Paula", "age" => "43"},
      ])
    end

    it "gets empty JSON params when nested key is missing" do
      request = build_request body: "{}",
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([] of Hash(String, String))
    end

    it "handles JSON with charset directive in Content-Type header" do
      request = build_request body: {users: [{name: "Paul", age: 28}]}.to_json,
        content_type: "application/json; charset=UTF-8"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([{"name" => "Paul", "age" => "28"}])
    end

    it "gets nested JSON params mixed with query params" do
      request = build_request body: {users: [{name: "Bunyan", age: 102}]}.to_json,
        content_type: "application/json"
      request.query = "users[0]:active=true"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([
        {"name" => "Bunyan", "age" => "102", "active" => "true"},
      ])
    end

    it "gets nested multipart params" do
      request = build_multipart_request form_parts: {
        "users" => [
          {"name" => "Paul", "age" => "28"},
          {"name" => "Paula", "age" => "32"},
        ],
      }

      params = Lucky::Params.new(request)

      params.many_nested(:users).should eq([
        {"name" => "Paul", "age" => "28"},
        {"name" => "Paula", "age" => "32"},
      ])
    end

    it "gets nested query params" do
      request = build_request body: "filters[0]:toppings=left_beef&filters[1]:type=none", content_type: ""
      request.query = "filters[0]:query=pizza&sort=desc"
      params = Lucky::Params.new(request)
      params.many_nested?("filters").should eq([
        {"query" => "pizza", "toppings" => "left_beef"},
        {"type" => "none"},
      ])
    end

    it "returns an empty array when no nested is found" do
      request = build_request body: "", content_type: ""
      request.query = "a=1"
      params = Lucky::Params.new(request)
      params.many_nested?("a").empty?.should eq true
    end

    it "gets nested params after unescaping" do
      request = build_request body: "users%5B0%5D%3Aname=paul",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.many_nested?(:users).should eq([{"name" => "paul"}])
    end

    it "raises if nested params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingNestedParamError do
        params.many_nested(:missing)
      end
    end

    it "returns empty array if nested_params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.many_nested?(:missing).should eq([] of Hash(String, String))
    end
  end

  describe "to_h" do
    it "returns a hash for query_params" do
      request = build_request body: "", content_type: ""
      request.query = "filter:name=trombone&page=1&per=50"
      params = Lucky::Params.new(request).to_h
      params.should eq({"filter" => {"name" => "trombone"}, "page" => "1", "per" => "50"})
    end

    it "returns a hash for body_params" do
      request = build_request body: "filter%3Aname=tuba&page=1&per=50",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request).to_h
      params.should eq({"filter" => {"name" => "tuba"}, "page" => "1", "per" => "50"})
    end

    it "returns a hash for multipart_params" do
      request = build_multipart_request form_parts: {"filter" => {"name" => "baritone"}}

      params = Lucky::Params.new(request).to_h
      params.should eq({"filter" => {"name" => "baritone"}})
    end

    it "returns a hash for json_params" do
      request = build_request body: {filter: {name: "euphonium"}}.to_json,
        content_type: "application/json"
      request.query = "page=1&per=50"

      params = Lucky::Params.new(request).to_h
      params.should eq({"filter" => {"name" => "euphonium"}, "page" => "1", "per" => "50"})
    end
  end
end
