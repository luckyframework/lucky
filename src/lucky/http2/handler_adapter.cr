class Lucky::HTTP2::HandlerAdapter
  private getter middleware : Array(HTTP::Handler)
  private getter route_handler : Lucky::HTTP2::RouteHandler

  def initialize(@middleware : Array(HTTP::Handler))
    @route_handler = Lucky::HTTP2::RouteHandler.new
  end

  def call(request : HT2::Request, response : HT2::Response)
    context = HT2::Context.new(request, response)
    unless route_handler.call(context)
      http_context = build_context(request, response)
      call_middleware(http_context)
    end
  end

  private def build_context(request : HT2::Request, response : HT2::Response)
    http_request = HTTP::Request.new(
      method: request.method.to_s,
      resource: request.uri.to_s,
      headers: request.headers,
      body: request.body.as(IO?)
    )
    response_io = Lucky::HTTP2::ResponseIO.new(response)
    http_response = HTTP::Server::Response.new(response_io)
    HTTP::Server::Context.new(http_request, http_response)
  end

  private def call_middleware(context : HTTP::Server::Context)
    handler = middleware.first
    handler.call(context)
  end
end
