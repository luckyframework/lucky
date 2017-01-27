abstract class LuckyWeb::Action
  getter :context, :path_params

  def initialize(@context : HTTP::Server::Context, @path_params : Hash(String, String))
  end

  macro inherited
    include LuckyWeb::Routeable
  end

  abstract def call : LuckyWeb::Response

  macro render
    view = {{ @type.name.gsub(/Action/, "HTML") }}.new
    body = view.render.to_s
    LuckyWeb::Response.new(context, "text/html", body)
  end

  def query_param(name)
    context.request.query_params[name.to_s]
  end

  def perform_action
    response = call
    handle_response(response)
  end

  private def handle_response(response : LuckyWeb::Response)
    response.print
  end

  private def render_text(body)
    LuckyWeb::Response.new(context, "text/plain", body)
  end
end
