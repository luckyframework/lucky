require "../spec_helper"

class HelloWorldAction < TestAction
  accepted_formats [:plain_text]

  post "/hello" do
    plain_text "world"
  end
end

class MyClient < Lucky::BaseHTTPClient
end

describe Lucky::BaseHTTPClient do
  describe "headers" do
    it "sets headers and allows chaining" do
      with_fake_server do |server|
        MyClient.for_app(server)
          .headers(accept: "text/plain")
          .headers(content_type: "application/json")
          .headers("Foo": "bar")
          .exec(HelloWorldAction)

        request = server.last_request
        request.headers["accept"].should eq("text/plain")
        request.headers["content-type"].should eq("application/json")
        request.headers["Foo"].should eq("bar")
      end
    end
  end

  describe "exec" do
    describe "with Lucky::Action class" do
      it "uses the method and path" do
        with_fake_server do |server|
          response = MyClient.for_app(server).exec(HelloWorldAction)

          request = server.last_request
          request.path.should eq "/hello"
          request.method.should eq("POST")
          request.body.not_nil!.gets_to_end.should eq("{}")
          response.body.should eq "world"
        end
      end

      it "allows passing params" do
        with_fake_server do |server|
          response = MyClient.for_app(server).exec(HelloWorldAction, foo: "bar")

          request = server.last_request
          request.body.not_nil!.gets_to_end.should eq({foo: "bar"}.to_json)
        end
      end
    end

    describe "with a Lucky::RouteHelper" do
      it "uses the method and path" do
        with_fake_server do |server|
          response = MyClient.for_app(server).exec(HelloWorldAction.route)

          request = server.last_request
          request.path.should eq "/hello"
          request.method.should eq("POST")
          request.body.not_nil!.gets_to_end.should eq("{}")
          response.body.should eq "world"
        end
      end

      it "allows passing params" do
        with_fake_server do |server|
          response = MyClient.for_app(server).exec(HelloWorldAction.route, foo: "bar")

          request = server.last_request
          request.body.not_nil!.gets_to_end.should eq({foo: "bar"}.to_json)
        end
      end
    end
  end

  {% for method in [:put, :patch, :post, :delete, :get, :options] %}
    describe "\#{{method.id}}" do
      it "sends correct request to correct uri and gives the correct response" do
        with_fake_server do |server|
          response = MyClient.for_app(server).{{method.id}}(
            path: "hello",
            foo: "bar"
          )

          request = server.last_request
          request.method.should eq({{ method.id.stringify }}.upcase)
          request.path.should eq "hello"
          request.body.not_nil!.gets_to_end.should eq({foo: "bar"}.to_json)
        end
      end

      it "works without params" do
        with_fake_server do |server|
          response = MyClient.for_app(server).{{method.id}}(path: "hello")

          request = server.last_request
          request.method.should eq({{ method.id.stringify }}.upcase)
          request.path.should eq "hello"
          request.body.not_nil!.gets_to_end.should eq("{}")
        end
      end
    end
  {% end %}
end

describe "head" do
  it "sends the correct request to the correct uri and gets an empty response body" do
    with_fake_server do |server|
      response = MyClient.for_app(server).head(
        path: "hello",
        foo: "bar"
      )

      request = server.last_request
      request.method.should eq("HEAD")
      request.path.should eq "hello"
    end
  end
  it "works without params" do
    with_fake_server do |server|
      response = MyClient.for_app(server).head(path: "hello")

      request = server.last_request
      request.method.should eq("HEAD")
      request.path.should eq "hello"
      request.body.not_nil!.gets_to_end.should eq("{}")
    end
  end
end

private def with_fake_server
  TestServer.middleware << Lucky::RouteHandler.new
  yield TestServer.new
ensure
  TestServer.reset
end
