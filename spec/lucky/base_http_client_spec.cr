require "../spec_helper"

class HelloWorldAction < TestAction
  accepted_formats [:plain_text]

  post "/hello" do
    plain_text "world"
  end
end

class MyClient < Lucky::BaseHTTPClient
  app TestServer.new
end

describe Lucky::BaseHTTPClient do
  describe "headers" do
    it "sets headers and allows chaining" do
      MyClient.new
        .headers(accept: "text/plain")
        .headers(content_type: "application/json")
        .headers("Foo": "bar")
        .exec(HelloWorldAction)

      request = TestServer.last_request
      request.headers["accept"].should eq("text/plain")
      request.headers["content-type"].should eq("application/json")
      request.headers["Foo"].should eq("bar")
    end
  end

  describe "exec" do
    describe "with Lucky::Action class" do
      it "uses the method and path" do
        response = MyClient.new.exec(HelloWorldAction)

        request = TestServer.last_request
        request.path.should eq "/hello"
        request.method.should eq("POST")
        request.body.to_s.should eq("{}")
        response.body.should eq "world"
      end

      it "allows passing params" do
        response = MyClient.new.exec(HelloWorldAction, foo: "bar")

        request = TestServer.last_request
        request.body.to_s.should eq({foo: "bar"}.to_json)
      end
    end

    describe "with a Lucky::RouteHelper" do
      it "uses the method and path" do
        response = MyClient.new.exec(HelloWorldAction.route)

        request = TestServer.last_request
        request.path.should eq "/hello"
        request.method.should eq("POST")
        request.body.to_s.should eq("{}")
        response.body.should eq "world"
      end

      it "allows passing params" do
        response = MyClient.new.exec(HelloWorldAction.route, foo: "bar")

        request = TestServer.last_request
        request.body.to_s.should eq({foo: "bar"}.to_json)
      end
    end
  end

  describe "exec_raw" do
    describe "with Lucky::Action class" do
      it "allows passing raw strings" do
        test_data = <<-JSON
          { "event_id": "1"}
          { "type": "event"}
          { "event_id": "2", "type": "event", "platform": ""}
        JSON
        response = MyClient.new.exec_raw(HelloWorldAction, test_data)

        request = TestServer.last_request
        request.body.to_s.should eq(test_data)
      end
    end

    describe "with a Lucky::RouteHelper" do
      it "allows passing raw strings" do
        test_data = <<-JSON
          { "event_id": "1"}
          { "type": "event"}
          { "event_id": "2", "type": "event", "platform": ""}
        JSON
        response = MyClient.new.exec_raw(HelloWorldAction.route, test_data)

        request = TestServer.last_request
        request.body.to_s.should eq(test_data)
      end
    end
  end

  {% for method in [:put, :patch, :post, :delete, :get, :options] %}
    describe "\#{{method.id}}" do
      it "sends correct request to correct uri and gives the correct response" do
        response = MyClient.new.{{method.id}}(
          path: "hello",
          foo: "bar"
        )

        request = TestServer.last_request
        request.method.should eq({{ method.id.stringify }}.upcase)
        request.path.should eq "hello"
        request.body.to_s.should eq({foo: "bar"}.to_json)
      end

      it "works without params" do
        response = MyClient.new.{{method.id}}(path: "hello")

        request = TestServer.last_request
        request.method.should eq({{ method.id.stringify }}.upcase)
        request.path.should eq "hello"
        request.body.to_s.should eq("{}")
      end
    end
  {% end %}

  describe "head" do
    it "sends the correct request to the correct uri and gets an empty response body" do
      response = MyClient.new.head(
        path: "hello",
        foo: "bar"
      )

      request = TestServer.last_request
      request.method.should eq("HEAD")
      request.path.should eq "hello"
    end
    it "works without params" do
      response = MyClient.new.head(path: "hello")

      request = TestServer.last_request
      request.method.should eq("HEAD")
      request.path.should eq "hello"
      request.body.to_s.should eq("{}")
    end
  end
end
