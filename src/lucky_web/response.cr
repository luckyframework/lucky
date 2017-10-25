class LuckyWeb::Response
  getter :context, :content_type, :body, :status

  def initialize(@context : HTTP::Server::Context, @content_type : String, @body : String, @status : Int32 = 200)
  end

  def print
    context.response.content_type = content_type
    context.response.status_code = status
    context.response.print body
  end
end
