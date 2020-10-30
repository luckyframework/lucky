require "http/client"

# A client for making HTTP requests
#
# Makes it easy to pass params, use Lucky route helpers, and chain header methods.
abstract class Lucky::BaseHTTPClient
  private getter client

  @client : HTTP::Client

  def initialize(host = Lucky::Server.settings.host, port = Lucky::Server.settings.port)
    @client = HTTP::Client.new(host, port: port)
  end

  {% for method in [:get, :put, :patch, :post, :exec, :delete, :options, :head] %}
    def self.{{ method.id }}(*args, **named_args)
      new.{{ method.id }}(*args, **named_args)
    end
  {% end %}

  # Set headers for requests
  #
  # ```
  # # `content_type` will be normalized to `content-type`
  # AppClient.new.headers(content_type: "application/json")
  #
  # # You can also use string keys if you want
  # AppClient.new.headers("Content-Type": "application/json")
  # ```

  # The header call is chainable and returns the client:
  #
  # ```
  # # content_type will be normalized to `content-type`
  # AppClient.new
  #   .headers(content_type: "application/json")
  #   .headers(accept: "text/plain")
  #   .get("/some-path")
  # ```
  #
  # You can also set up headers in `initialize` or in instance methods:
  #
  # ```
  # class AppClient < Lucky::BaseHTTPClient
  #   def initialize
  #     headers(content_type: "application/json")
  #   end
  #
  #   def accept_plain_text
  #     headers(accept: "text/plain")
  #   end
  # end
  #
  # AppClient.new
  #   .accept_plain_text
  #   .get("/some-path")
  # ```
  def headers(**header_values)
    @client.before_request do |request|
      header_values.each do |key, value|
        request.headers[key.to_s.gsub("-", "_")] = value.to_s
      end
    end
    self
  end

  # Sends a request with the path and method from a Lucky::Action
  #
  # ```
  # # Make a request without body params
  # AppClient.new.exec Users::Index
  #
  # # Make a request with body params
  # AppClient.new.exec Users::Create, user: {email: "paul@example.com"}
  #
  # # Actions that require path params work like normal
  # AppClient.new.exec Users::Show.with(user.id)
  # ```
  def exec(action : Lucky::Action.class, **params) : HTTP::Client::Response
    exec(action.route, params)
  end

  # See docs for `exec`
  def exec(route_helper : Lucky::RouteHelper, **params) : HTTP::Client::Response
    exec(route_helper, params)
  end

  # See docs for `exec`
  def exec(route_helper : Lucky::RouteHelper, params : NamedTuple) : HTTP::Client::Response
    @client.exec(method: route_helper.method.to_s.upcase, path: route_helper.path, body: params.to_json)
  end

  {% for method in [:put, :patch, :post, :delete, :get, :options, :head] %}
    def {{ method.id }}(path : String, **params) : HTTP::Client::Response
      {{ method.id }}(path, params)
    end

    def {{ method.id }}(path : String, params : NamedTuple) : HTTP::Client::Response
      @client.{{ method.id }}(path, form: params.to_json)
    end
  {% end %}
end
