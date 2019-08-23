require "http/request"
require "http/server"

class TestServer
  delegate listen, close, to: @server

  class_property routes : Hash(String, String) = {} of String => String

  property! last_request : HTTP::Request?
  getter port

  def initialize(@port : Int32)
    @server = HTTP::Server.new do |context|
      last_request = context.request.dup
      last_request.body = last_request.body.try(&.peek)
      @last_request = last_request
      response_body = self.class.routes[context.request.path]
      context.response.content_type = "text/plain"
      context.response.print response_body
    end
    @server.bind_tcp port: port
  end

  def self.route(path : String, response_body : String)
    routes[path] = response_body
  end

  def self.reset
    self.routes = {} of String => String
  end
end
