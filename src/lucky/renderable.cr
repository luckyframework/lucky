module Lucky::Renderable
  # Render a page and pass it data
  #
  # `render` is used to pass data to a page. Each key/value pair must match up
  # with each `needs` declarations for that page. For example, if we have a
  # page like this:
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
  # Our action must pass a `users` key to the `render` method like this:
  #
  # ```crystal
  # class Users::Index < BrowserAction
  #   route do
  #     render IndexPage, users: UserQuery.new
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
  #     render IndexPage users: UserQuery.new
  #   end
  #
  #   private def current_user
  #     # ...
  #   end
  # end
  # ```
  macro render(page_class = nil, **assigns)
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
      body
    )
  end

  # :nodoc:
  def perform_action
    response = call
    handle_response(response)
  end

  private def handle_response(response : Lucky::Response)
    log_response(response)
    response.print
  end

  private def log_response(response : Lucky::Response)
    response.debug_message.try do |message|
      Lucky.logger.debug(message)
    end
  end

  private def file(path,
                   content_type : String? = nil,
                   disposition : String = "attachment",
                   filename : String? = nil,
                   status : Int32? = nil)
    Lucky::FileResponse.new(context, path, content_type, disposition, filename, status)
  end

  private def file(path,
                   content_type : String? = nil,
                   disposition : String = "attachment",
                   filename : String? = nil,
                   status : Lucky::Action::Status = Lucky::Action::Status::OK)
    file(path, content_type, disposition, filename, status.value)
  end

  private def text(body, status : Int32? = nil)
    Lucky::TextResponse.new(context, "text/plain", body, status: status)
  end

  private def text(body, status : Lucky::Action::Status)
    Lucky::TextResponse.new(context, "text/plain", body, status: status.value)
  end

  private def render_text(*args, **named_args)
    text(*args, **named_args)
  end

  private def head(status : Int32)
    Lucky::TextResponse.new(context, content_type: "", body: "", status: status)
  end

  private def head(status : Lucky::Action::Status)
    head(status.value)
  end

  private def json(body, status : Int32? = nil)
    Lucky::TextResponse.new(context, "application/json", body.to_json, status)
  end

  private def json(body, status : Lucky::Action::Status = nil)
    json(body, status.value)
  end
end
