require "../spec_helper"

include ContextHelper
include MultipartHelper

describe Lucky::Params do
  describe "#from_query" do
    it "returns the HTTP::Params for the query params" do
      request = build_request
      request.query = "q=test"

      params = Lucky::Params.new(request)

      params.from_query.should be_a(HTTP::Params)
      params.from_query["q"].should eq("test")
    end
  end

  describe "#from_json" do
    it "returns a JSON::Any object" do
      request = build_request(body: {page: 1}.to_json)

      params = Lucky::Params.new(request)

      params.from_json.should be_a(JSON::Any)
      params.from_json["page"].as_i.should eq(1)
    end
  end

  describe "#from_form_data" do
    it "returns HTTP::Params based on the request body" do
      request = build_request body: "name=Ben",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.from_form_data.should be_a(HTTP::Params)
      params.from_form_data["name"].should eq("Ben")
    end
  end

  describe "#from_multipart" do
    it "returns a Tuple with form data in first position" do
      request = build_multipart_request form_parts: {"from" => "multipart"}

      params = Lucky::Params.new(request)

      params.from_multipart.first["from"].should eq("multipart")
    end

    it "returns a Tuple with files in second position" do
      request = build_multipart_request file_parts: {
        "avatar" => "file_contents",
      }

      params = Lucky::Params.new(request)

      file = params.from_multipart.last["avatar"]
      file.should be_a(Lucky::UploadedFile)
      File.read(file.path).should eq "file_contents"
    end
  end

  it "works when parsing params twice" do
    request = build_request body: "from=form",
      content_type: "application/x-www-form-urlencoded",
      fixed_length: true

    params = Lucky::Params.new(request)

    params.get?(:from).should eq "form"
    params.get?(:from).should eq "form"
  end

  it "works when parsing multipart params twice" do
    request = build_multipart_request form_parts: {
      "user" => {
        "name" => "Paul",
        "age"  => "28",
      },
    }

    params = Lucky::Params.new(request)

    params.nested?(:user).should eq({"name" => "Paul", "age" => "28"})
    params.nested?(:user).should eq({"name" => "Paul", "age" => "28"})
  end

  it "works when parsing json params twice" do
    request = build_request body: {page: 1}.to_json,
      content_type: "application/json",
      fixed_length: true

    params = Lucky::Params.new(request)

    params.get?(:page).should eq "1"
    params.get?(:page).should eq "1"
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
    it "strips whitespace around values" do
      request = build_request body: "", content_type: ""
      request.query = "email= paul@luckyframework.org &name= Paul "

      params = Lucky::Params.new(request)

      params.get?(:email).should eq "paul@luckyframework.org"
      params.get?(:name).should eq "Paul"
    end

    it "raises if missing a param and using get version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get(:missing)
      end
    end

    it "returns nil if using get? version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get?(:missing).should be_nil
    end
  end

  describe "get_raw" do
    it "parses form encoded params" do
      request = build_request body: "page=1&foo=bar",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get_raw?(:page).should eq "1"
      params.get_raw?(:foo).should eq "bar"
    end

    it "parses JSON params" do
      request = build_request body: {page: 1, foo: "bar"}.to_json,
        content_type: "application/json"

      params = Lucky::Params.new(request)

      params.get_raw?(:page).should eq "1"
      params.get_raw?(:foo).should eq "bar"
    end

    it "handles empty JSON body" do
      request = build_request body: "",
        content_type: "application/json"

      params = Lucky::Params.new(request)

      # Should not raise
      params.get_raw?(:anything)
    end

    it "handles JSON with charset directive in Content-Type header" do
      request = build_request body: {page: 1, foo: "bar"}.to_json,
        content_type: "application/json;charset=UTF-8"

      params = Lucky::Params.new(request)

      params.get_raw?(:page).should eq "1"
      params.get_raw?(:foo).should eq "bar"
    end

    it "parses query params" do
      request = build_request body: "", content_type: ""
      request.query = "page=1&id=1"

      params = Lucky::Params.new(request)

      params.get_raw?(:page).should eq "1"
      params.get_raw?(:id).should eq "1"
    end

    it "parses params in multipart requests" do
      request = build_multipart_request form_parts: {"from" => "multipart"}

      params = Lucky::Params.new(request)

      params.get_raw(:from).should eq "multipart"
    end

    it "raises if missing a param and using get_raw version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get_raw(:missing)
      end
    end

    it "returns nil if using get_raw? version" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get_raw?(:missing).should be_nil
    end

    it "does not strip whitespace around values" do
      request = build_request body: "", content_type: ""
      request.query = "email= paul@luckyframework.org  &name= Paul &age=28 "

      params = Lucky::Params.new(request)

      params.get_raw?(:email).should eq " paul@luckyframework.org  "
      params.get_raw?(:name).should eq " Paul "
      params.get_raw?(:age).should eq "28 "
    end
  end

  describe "#get_all" do
    it "raises if no values found" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get_all(:missing)
      end
    end

    it "does not return values from route params" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"
      route_params = {"id" => "from_route"}

      params = Lucky::Params.new(request, route_params)

      expect_raises Lucky::MissingParamError do
        params.get_all(:id)
      end
    end

    it "returns array from json if found" do
      request = build_request body: {labels: ["crystal", "lucky"]}.to_json, content_type: "application/json"

      params = Lucky::Params.new(request)

      params.get_all(:labels).should eq(["crystal", "lucky"])
    end

    it "returns value to string in array if json value is not array" do
      request = build_request body: {titles: "not a list"}.to_json, content_type: "application/json"

      params = Lucky::Params.new(request)

      params.get_all(:titles).should eq(["not a list"])
    end

    it "returns multipart params if found" do
      request = build_multipart_request form_parts: {"from" => ["asher", "lila"]}

      params = Lucky::Params.new(request)

      params.get_all(:from).should eq(["asher", "lila"])
    end

    it "returns form encoded params if found" do
      request = build_request body: "tags[]=funny&tags[]=complex", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get_all(:tags).should eq(["funny", "complex"])
    end

    it "returns query params if found" do
      request = build_request body: "", content_type: ""
      request.query = "referrers[]=social&referrers[]=email"

      params = Lucky::Params.new(request)

      params.get_all(:referrers).should eq(["social", "email"])
    end

    it "requires params to end with square brackets" do
      request = build_request body: "", content_type: ""
      request.query = "names=declan&names=nora"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingParamError do
        params.get_all(:names)
      end
    end
  end

  describe "#get_all?" do
    it "returns nil if values not found" do
      request = build_request body: "", content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.get_all?(:missing).should be_nil
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

    it "gets nested JSON containing nested JSON" do
      request = build_request body: {user: {name: "Paul", address: {home: "1600 Pennsylvania Ave"}}}.to_json,
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.nested?(:user).should eq({"name" => "Paul", "address" => "{\"home\":\"1600 Pennsylvania Ave\"}"})
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

  describe "nested_arrays" do
    it "gets nested arrays from form encoded params" do
      request = build_request body: "user:name=paul&user:langs[]=ruby&user:langs[]=elixir",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({"langs" => ["ruby", "elixir"]})
    end

    it "gets nested arrays from JSON params" do
      request = build_request body: {user: {name: "Paul", langs: ["ruby", "elixir"]}}.to_json,
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({"langs" => ["ruby", "elixir"]})
    end

    it "gets empty JSON params when nested key is missing" do
      request = build_request body: "{}",
        content_type: "application/json"
      request.query = "from=query"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({} of String => JSON::Any)
    end

    it "handles JSON with charset directive in Content-Type header" do
      request = build_request body: {user: {name: "Paul", langs: ["ruby", "elixir"]}}.to_json,
        content_type: "application/json; charset=UTF-8"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({"langs" => ["ruby", "elixir"]})
    end

    it "gets nested array JSON params mixed with query params" do
      request = build_request body: {user: {name: "Bunyan", tags: ["tall"]}}.to_json,
        content_type: "application/json"
      request.query = "user:tags[]=tale"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({"tags" => ["tall", "tale"]})
    end

    it "gets nested arrays from multipart params" do
      request = build_multipart_request form_parts: {
        "user:name" => "Paul", "user:langs" => ["ruby", "elixir"],
      }

      params = Lucky::Params.new(request)

      params.nested_arrays?(:user).should eq({"langs" => ["ruby", "elixir"]})
    end

    it "gets nested arrays from query params" do
      request = build_request body: "filter:toppings[]=sausage", content_type: ""
      request.query = "filter:toppings[]=black_olive"
      params = Lucky::Params.new(request)
      params.nested_arrays?("filter").should eq({"toppings" => ["sausage", "black_olive"]})
    end

    it "returns an empty hash when no nested array is found" do
      request = build_request body: "", content_type: ""
      request.query = "a[]=1"
      params = Lucky::Params.new(request)
      params.nested_arrays?("a").empty?.should eq true
    end

    it "gets nested array params after unescaping" do
      request = build_request body: "post%3Atags[]=coding",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:post).should eq({"tags" => ["coding"]})
    end

    it "raises if nested array params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingNestedParamError do
        params.nested_arrays(:missing)
      end
    end

    it "returns empty hash if nested array params are missing" do
      request = build_request body: "",
        content_type: "application/x-www-form-urlencoded"

      params = Lucky::Params.new(request)

      params.nested_arrays?(:missing).should eq({} of String => Array(String))
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

  describe "nested_array_files" do
    it "gets multipart nested array params" do
      request = build_multipart_request file_parts: {
        "user:photos" => ["cat", "dog"],
      }

      params = Lucky::Params.new(request)

      files = params.nested_array_files(:user)["photos"]
      files.size.should eq(2)
      File.read(files[0].path).should eq("cat")
      File.read(files[1].path).should eq("dog")
    end

    it "raises if nested array files are missing" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      expect_raises Lucky::MissingNestedParamError do
        params.nested_array_files(:missing)
      end
    end

    it "returns empty hash if nested array files are missing" do
      request = build_multipart_request form_parts: {"this" => "that"}

      params = Lucky::Params.new(request)

      params.nested_array_files?(:missing).should eq({} of String => Array(Lucky::UploadedFile))
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

  describe "Setting route_params later" do
    it "returns the correct values for get?" do
      request = build_request body: "", content_type: ""
      route_params = {"id" => "from_route"}
      params = Lucky::Params.new(request)

      params.get?(:id).should eq nil

      params.route_params = route_params
      params.get?(:id).should eq "from_route"
    end
  end
end
