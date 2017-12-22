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
    body = view.perform_render.to_s
    Lucky::Response.new(
      context,
      "text/html",
      body,
      debug_message: log_message(view),
    )
  end

  private def log_message(view)
    "Rendered #{view.class.colorize(HTTP::Server::Context::DEBUG_COLOR)}"
  end

  def perform_action
    response = call
    handle_response(response)
  end

  private def handle_response(response : Lucky::Response)
    log_response(response)
    response.print
  end

  private def handle_response(_response : T) forall T
    {%
      raise <<-ERROR

      #{@type} returned #{T}, but it must return a Lucky::Response.

      Try this...
        ▸ Make sure to use a method like `render`, `redirect`, or `json` at the end of your action.
        ▸ If you are using a conditional, make sure all branches return a Lucky::Response.
      ERROR
    %}
  end

  private def log_response(response : Lucky::Response)
    response.debug_message.try do |message|
      context.add_debug_message(message)
    end
  end

  private def render_text(body, status : Int32? = nil)
    Lucky::Response.new(context, "text/plain", body, status: status)
  end

  private def render_text(body, status : Lucky::Action::Status)
    Lucky::Response.new(context, "text/plain", body, status: status.value)
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
