module Lucky::Renderable
  # Render a page and pass it data
  #
  # `html` is used to pass data to a page and render it. Each key/value pair
  # must match up with each `needs` declarations for that page. For example, if
  # we have a page like this:
  #
  # ```crystal
  # class Users::IndexPage < MainLayout
  #   needs users : UserQuery
  #
  #   def content
  #     @users.each do |user|
  #       # ...
  #     end
  #   end
  # end
  # ```
  #
  # Our action must pass a `users` key to the `html` method like this:
  #
  # ```crystal
  # class Users::Index < BrowserAction
  #   route do
  #     html IndexPage, users: UserQuery.new
  #   end
  # end
  # ```
  #
  # Note also that each piece of data is merged with any `expose` declarations:
  #
  # ```crystal
  # class Users::Index < BrowserAction
  #   expose current_user
  #
  #   route do
  #     # Users::IndexPage receives users AND current_user
  #     html IndexPage users: UserQuery.new
  #   end
  #
  #   private def current_user
  #     # ...
  #   end
  # end
  # ```
  macro html(page_class = nil, **assigns)
    validate_page_class!({{ page_class }})

    render_html_page(
      {{ page_class = page_class || "#{@type.name}Page".id }},
      {% if assigns.empty? %}
        {} of String => String
      {% else %}
        {{ assigns }}
      {% end %}
    )
  end

  macro validate_page_class!(page_class)
    {% if page_class && page_class.resolve? %}
      {% ancestors = page_class.resolve.ancestors %}

      {% if ancestors.includes?(Lucky::Action) %}
        {% page_class.raise "You accidentally rendered an action (#{page_class}) instead of an HTMLPage in the #{@type.name} action. Did you mean #{page_class}Page?" %}
      {% elsif !ancestors.includes?(Lucky::HTMLPage) %}
        {% page_class.raise "Couldn't render #{page_class} in #{@type.name} because it is not an HTMLPage" %}
      {% end %}
    {% end %}
  end

  # :nodoc:
  macro render_html_page(page_class, assigns)
    view = {{ page_class }}.new(
      context: context,
      {% for key, value in assigns %}
        {{ key }}: {{ value }},
      {% end %}
      {% for key in EXPOSURES %}
        {{ key }}: {{ key }},
      {% end %}
    )
    body = view.perform_render.to_s
    Lucky::TextResponse.new(
      context,
      "text/html",
      body,
      debug_message: log_message(view),
    )
  end

  private def log_message(view) : String
    "Rendered #{view.class.colorize.bold}"
  end

  # :nodoc:
  def perform_action : Nil
    response = call
    handle_response(response)
  end

  private def handle_response(response : Lucky::Response) : Nil
    log_response(response)
    response.print
  end

  private def handle_response(_response : T) forall T
    {%
      raise <<-ERROR


      Your action returned #{T}

      But it should return a Lucky::Response

      Try this...

        ▸ Use a method like render/redirect/json at the end of your action.
        ▸ Ensure all conditionals (like if/else) return a response with render/redirect/json/etc.
      ERROR
    %}
  end

  private def log_response(response : Lucky::Response) : Nil
    response.debug_message.try do |message|
      Lucky.logger.debug(message)
    end
  end

  private def file(path : String,
                   content_type : String? = nil,
                   disposition : String = "attachment",
                   filename : String? = nil,
                   status : Int32? = nil) : Lucky::FileResponse
    Lucky::FileResponse.new(context, path, content_type, disposition, filename, status)
  end

  private def file(path : String,
                   content_type : String? = nil,
                   disposition : String = "attachment",
                   filename : String? = nil,
                   status : HTTP::Status = HTTP::Status::OK) : Lucky::FileResponse
    file(path, content_type, disposition, filename, status.value)
  end

  private def send_text_response(body : String, content_type : String, status : Int32? = nil) : Lucky::TextResponse
    Lucky::TextResponse.new(context, content_type, body, status: status)
  end

  private def plain_text(body : String, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body, "text/plain", status)
  end

  private def plain_text(body : String, status : HTTP::Status) : Lucky::TextResponse
    plain_text(body, status: status.value)
  end

  private def text(*args, **named_args)
    {% raise "'text' in actions has been renamed to 'plain_text'" %}
  end

  @[Deprecated("`render_text deprecated. Use `plain_text` instead")]
  private def render_text(*args, **named_args) : Lucky::TextResponse
    plain_text(*args, **named_args)
  end

  private def head(status : Int32) : Lucky::TextResponse
    send_text_response(body: "", content_type: "", status: status)
  end

  private def head(status : HTTP::Status) : Lucky::TextResponse
    head(status.value)
  end

  private def json(body, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body.to_json, "application/json", status)
  end

  private def json(body, status : HTTP::Status) : Lucky::TextResponse
    json(body, status: status.value)
  end

  private def xml(body : String, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body, "text/xml", status)
  end

  private def xml(body, status : HTTP::Status) : Lucky::TextResponse
    xml(body, status: status.value)
  end
end
