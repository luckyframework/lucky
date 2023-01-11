require "http/client"

# A client for making HTTP requests
#
# Makes it easy to pass params, use Lucky route helpers, and chain header methods.
abstract class Lucky::BaseHTTPClient
  @@app : Lucky::BaseAppServer?
  private getter client

  @client : HTTP::Client

  def self.app(@@app : Lucky::BaseAppServer)
  end

  def initialize(@client = build_client)
  end

  private def build_client : HTTP::Client
    if app = @@app
      Client.from_app(app)
    else
      HTTP::Client.new(Lucky::Server.settings.host, port: Lucky::Server.settings.port)
    end
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
  def headers(**header_values) : self
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

  # `exec_raw` works the same as `exec`, but allows you to pass in a raw string.
  # This is used as an escape hatch as the `string` could be unsafe, or formatted
  # in a custom format.
  def exec_raw(action : Lucky::Action.class, body : String) : HTTP::Client::Response
    exec_raw(action.route, body)
  end

  # See docs for `exec_raw`
  def exec_raw(route_helper : Lucky::RouteHelper, body : String) : HTTP::Client::Response
    @client.exec(method: route_helper.method.to_s.upcase, path: route_helper.path, body: body)
  end

  {% for method in [:put, :patch, :post, :delete, :get, :options, :head] %}
    def {{ method.id }}(path : String, **params) : HTTP::Client::Response
      {{ method.id }}(path, params)
    end

    def {{ method.id }}(path : String, params : NamedTuple) : HTTP::Client::Response
      @client.{{ method.id }}(path, form: params.to_json)
    end
  {% end %}

  # HTTP::Client that sends requests into the wrapped HTTP::Handler
  # instead of making actual HTTP requests
  private class Client < HTTP::Client
    @host = ""
    @port = -1

    def self.from_app(app : Lucky::BaseAppServer)
      self.new(HTTP::Server.build_middleware(app.middleware))
    end

    def initialize(@app : HTTP::Handler)
    end

    def exec_internal(request : HTTP::Request) : HTTP::Client::Response
      set_defaults(request)
      run_before_request_callbacks(request)
      buffer = IO::Memory.new
      response = HTTP::Server::Response.new(buffer)
      context = HTTP::Server::Context.new(request, response)

      @app.call(context)
      response.close

      HTTP::Client::Response.from_io(buffer.rewind)
    end
  end
end
