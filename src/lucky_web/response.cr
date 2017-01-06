class LuckyWeb::Response
  getter :context, :content_type, :body

  def initialize(@context : HTTP::Server::Context, @content_type : String, @body : String)
  end

  def print
    context.response.content_type = content_type
    context.response.print body
  end
end
