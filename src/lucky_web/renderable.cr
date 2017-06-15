module LuckyWeb::Renderable
  macro render(page, **assigns)
    view = {{ page }}.new(
      {% for key, value in assigns %}
        {{ key }}: {{ value }}
      {% end %}
    )
    body = view.render.to_s
    LuckyWeb::Response.new(context, "text/html", body)
  end

  macro render(**assigns)
    view = {{ "#{@type.name}Page".id }}.new(
      {% for key, value in assigns %}
        {{ key }}: {{ value }}
      {% end %}
    )
    body = view.render.to_s
    LuckyWeb::Response.new(context, "text/html", body)
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
