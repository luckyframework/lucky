module Lucky::Renderable
  macro render(page_class = nil, **assigns)
    render_html_page(
      {{ page_class || "#{@type.name}Page".id }},
      {% if assigns.empty? %}
        {} of String => String
      {% else %}
        {{ assigns }}
      {% end %}
    )
  end

  macro render_html_page(page_class, assigns)
    view = {{ page_class.id }}.new(
      {% for key, value in assigns %}
        {{ key }}: {{ value }},
      {% end %}
      {% for key in EXPOSURES %}
        {{ key }}: {{ key }},
      {% end %}
    )
    log_html_render(context, view)
    body = view.perform_render.to_s
    Lucky::Response.new(context, "text/html", body)
  end

  private def log_html_render(context, view)
    context.add_debug_message("Rendered #{view.class.colorize(HTTP::Server::Context::DEBUG_COLOR)}")
  end

  def perform_action
    response = call
    handle_response(response)
  end

  private def handle_response(response : Lucky::Response)
    response.print
  end

  private def handle_response(_response)
    {% raise "You must return a Lucky::Response from #{@type}. You can do that by using methods such as `render`, `redirect`, `json`" %}
  end

  private def render_text(body)
    Lucky::Response.new(context, "text/plain", body)
  end

  private def head(status : Int32)
    Lucky::Response.new(context, content_type: "", body: "", status: status)
  end

  private def head(status : Lucky::Action::Status)
    head(status.value)
  end

  private def json(body, status : Int32? = nil)
    Lucky::Response.new(context, "application/json", body.to_json, status)
  end

  private def json(body, status : Lucky::Action::Status = nil)
    json(body, status.value)
  end
end
