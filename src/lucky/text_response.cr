class Lucky::TextResponse < Lucky::Response
  DEFAULT_STATUS = 200

  getter context, content_type, body, debug_message

  def initialize(@context : HTTP::Server::Context,
                 @content_type : String,
                 @body : String,
                 @status : Int32? = nil,
                 @debug_message : String? = nil)
  end

  def print : Nil
    context.response.content_type = content_type
    context.response.status_code = status
    context.response.print body
  end

  def status : Int
    @status || context.response.status_code || DEFAULT_STATUS
  end
end
