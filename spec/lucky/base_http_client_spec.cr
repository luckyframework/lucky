require "../spec_helper"

server = TestServer.new(6226)

spawn do
  server.listen
end

Spec.before_each do
  TestServer.reset
end

describe Lucky::BaseHTTPClient do
  describe "#get" do
    it "sends requests to correct uri (with the correct query params) and gives the right response" do
      TestServer.route("hello", "world")
      Lucky::Server.temp_config(host: "localhost", port: 6226) do
        client = Lucky::BaseHTTPClient.new
        response = client.get("hello", params: HTTP::Params.new(raw_params: {"foo" => ["bar"]}))

        response.body.should eq "world"

        request = server.last_request.not_nil!
        params = request.query.not_nil!
        params.should eq HTTP::Params.encode({"foo" => "bar"})
      end
    end
  end

  describe "#delete" do
    it "sends requests to correct uri (with the correct query params) and gives the right response" do
      TestServer.route("hello", "world")
      Lucky::Server.temp_config(host: "localhost", port: 6226) do
        client = Lucky::BaseHTTPClient.new
        response = client.delete("hello")

        response.body.should eq "world"
      end
    end
  end

  {% for method in [:put, :patch, :post] %}

    describe "\#{{method.id}}" do
      it "sends correct request to correct uri and gives the correct response" do
        TestServer.route("hello", "world")
        Lucky::Server.temp_config(host: "localhost", port: 6226) do
          client = Lucky::BaseHTTPClient.new
          response = client.{{method.id}}(
            path: "hello",
            body: { "foo" => "bar" }
          )
          response.body.should eq "world"

          request = server.last_request.not_nil!
          body = request.body.not_nil!
          body.gets_to_end.should eq HTTP::Params.encode({ "foo" => "bar" })
        end
      end
    end

  {% end %}
end

at_exit do
  server.close
end
