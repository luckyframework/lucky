module Lucky::Renderable
  # Render a page and pass it data
  #
  # `html` is used to pass data to a page and render it. Each key/value pair
  # must match up with each `needs` declarations for that page. For example, if
  # we have a page like this:
  #
  # ```
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
  # ```
  # class Users::Index < BrowserAction
  #   get "/users" do
  #     html IndexPage, users: UserQuery.new
  #   end
  # end
  # ```
  #
  # Note also that each piece of data is merged with any `expose` declarations:
  #
  # ```
  # class Users::Index < BrowserAction
  #   expose current_user
  #
  #   get "/users" do
  #     # Users::IndexPage receives users AND current_user
  #     html IndexPage users: UserQuery.new
  #   end
  #
  #   private def current_user
  #     # ...
  #   end
  # end
  # ```
  macro html(page_class = nil, _with_status_code = 200, **assigns)
    {% page_class = page_class || "#{@type.name}Page".id %}
    validate_page_class!({{ page_class }})

    # Found in {{ @type.name }}
    view = {{ page_class }}.new(
      context: context,
      {% for key, value in assigns %}
        {{ key }}: {{ value }},
      {% end %}
      {% for key in EXPOSURES %}
        {{ key }}: {{ key }},
      {% end %}
    )
    Lucky::TextResponse.new(
      context,
      html_content_type,
      view.perform_render,
      status: {{ _with_status_code }},
      debug_message: log_message(view),
      enable_cookies: enable_cookies?
    )
  end

  # Render an HTMLPage with a status other than 200
  #
  # The status can either be a Number, a HTTP::Status, or a Symbol that corresponds to the HTTP::Status.
  #
  # ```
  # class SecretAgents::Index < BrowserAction
  #   get "/shhhh" do
  #     html_with_status IndexPage, 472, message: "This page can only be seen with special goggles"
  #   end
  # end
  # ```
  # See Crystal's
  # [HTTP::Status](https://crystal-lang.org/api/latest/HTTP/Status.html)
  # enum for more available http status codes.
  macro html_with_status(page_class, status, **assigns)
    {% if status.is_a?(SymbolLiteral) %}
      html {{ page_class }}, _with_status_code: HTTP::Status::{{ status.upcase.id }}.value, {{ **assigns }}
    {% elsif status.is_a?(Path) && status.names.join("::").starts_with?("HTTP::Status::") %}
      html {{ page_class }}, _with_status_code: {{ status.resolve }}, {{ **assigns }}
    {% else %}
      html {{ page_class }}, _with_status_code: {{ status }}, {{ **assigns }}
    {% end %}
  end

  # :nodoc:
  macro validate_page_class!(page_class)
    {% ancestors = page_class.resolve.ancestors %}

    {% if ancestors.includes?(Lucky::Action) %}
      {% page_class.raise "You accidentally rendered an action (#{page_class}) instead of an HTMLPage in the #{@type.name} action. Did you mean #{page_class}Page?" %}
    {% elsif !ancestors.includes?(Lucky::HTMLPage) %}
      {% page_class.raise "Couldn't render #{page_class} in #{@type.name} because it is not an HTMLPage" %}
    {% end %}
  end

  # Disable cookies
  #
  # When `disable_cookies` is used, no `Set-Cookie` header will be written to
  # the response.
  #
  # ```
  # class Events::Show < ApiAction
  #   disable_cookies
  #
  #   get "/events/:id" do
  #     ...
  #   end
  # end
  # ```
  #
  macro disable_cookies
    private def enable_cookies?
      false
    end
  end

  private def enable_cookies?
    true
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

  private def handle_response(_response : Nil)
    {%
      raise <<-ERROR


      An action returned Nil

      But it should return a Lucky::Response.

      Try this...

        ▸ Return a response with html, redirect, or json at the end of your action.
        ▸ Ensure all conditionals (like if/else) return a response with html, redirect, json, etc.

      For example...

        get "/admin/users" do
          # Make sure there is a response in all conditional branches
          if current_user.admin?
            html IndexPage, users: UserQuery.new
          else
            redirect Home::Index
          end
        end

      ERROR
    %}
  end

  private def handle_response(_response : T) forall T
    {%
      raise <<-ERROR


      An action returned #{T}

      But it should return a Lucky::Response

      Try this...

        ▸ Return a response with html, redirect, or json at the end of your action.
        ▸ Ensure all conditionals (like if/else) return a response with html, redirect, json, etc.

      For example...

        get "/users" do
          # Return a response with json, redirect, html, etc.
          html IndexPage, users: UserQuery.new
        end

      ERROR
    %}
  end

  private def log_response(response : Lucky::Response) : Nil
    response.debug_message.try do |message|
      Lucky::Log.debug { message }
    end
  end

  # The default global content-type header for HTML
  def html_content_type
    "text/html"
  end

  # The default global content-type header for JSON
  def json_content_type
    "application/json"
  end

  # The default global content-type header for XML
  def xml_content_type
    "text/xml"
  end

  # The default global content-type header for Plain text
  def plain_content_type
    "text/plain"
  end

  def file(
    path : String,
    content_type : String? = nil,
    disposition : String = "attachment",
    filename : String? = nil,
    status : Int32? = nil
  ) : Lucky::FileResponse
    Lucky::FileResponse.new(context, path, content_type, disposition, filename, status)
  end

  def file(
    path : String,
    content_type : String? = nil,
    disposition : String = "attachment",
    filename : String? = nil,
    status : HTTP::Status = HTTP::Status::OK
  ) : Lucky::FileResponse
    file(path, content_type, disposition, filename, status.value)
  end

  def data(
    data : String,
    content_type : String = "application/octet-stream",
    disposition : String = "attachment",
    filename : String? = nil,
    status : Int32? = nil
  ) : Lucky::DataResponse
    Lucky::DataResponse.new(context, data, content_type, disposition, filename, status)
  end

  def send_text_response(
    body : String,
    content_type : String,
    status : Int32? = nil
  ) : Lucky::TextResponse
    Lucky::TextResponse.new(
      context,
      content_type,
      body,
      status: status,
      enable_cookies: enable_cookies?
    )
  end

  def plain_text(body : String, status : Int32? = nil, content_type : String = plain_content_type) : Lucky::TextResponse
    send_text_response(body, content_type, status)
  end

  def plain_text(body : String, status : HTTP::Status, content_type : String = plain_content_type) : Lucky::TextResponse
    plain_text(body, status: status.value)
  end

  def head(status : Int32) : Lucky::TextResponse
    send_text_response(body: "", content_type: "", status: status)
  end

  def head(status : HTTP::Status) : Lucky::TextResponse
    head(status.value)
  end

  # allows json-compatible string to be returned directly
  def raw_json(body : String, status : Int32? = nil, content_type : String = json_content_type) : Lucky::TextResponse
    send_text_response(body, content_type, status)
  end

  def raw_json(body : String, status : HTTP::Status, content_type : String = json_content_type) : Lucky::TextResponse
    raw_json(body, status: status.value, content_type: content_type)
  end

  # :nodoc:
  def json(body : String, status : Int32? = nil, content_type : String = json_content_type) : Lucky::TextResponse
    {%
      raise <<-ERROR

      Looks like your trying to pass a string to json response.

      Use `raw_json(body, ...)` instead.

      NOTE: `raw_json` doesn't validate JSON string validity/integrity, use at your own risk.

      ERROR
    %}
  end

  def json(body, status : Int32? = nil, content_type : String = json_content_type) : Lucky::TextResponse
    raw_json(body.to_json, status, content_type)
  end

  def json(body, status : HTTP::Status, content_type : String = json_content_type) : Lucky::TextResponse
    json(body, status: status.value, content_type: content_type)
  end

  def xml(body : String, status : Int32? = nil, content_type : String = xml_content_type) : Lucky::TextResponse
    send_text_response(body, content_type, status)
  end

  def xml(body, status : HTTP::Status, content_type : String = xml_content_type) : Lucky::TextResponse
    xml(body, status: status.value, content_type: content_type)
  end

  # Render a Component as an HTML response.
  #
  # ```
  # get "/foo" do
  #   component MyComponent, with: :args
  # end
  # ```
  def component(comp : Lucky::BaseComponent.class, status : Int32? = nil, **named_args) : Lucky::TextResponse
    send_text_response(
      comp.new(**named_args).context(context).render_to_string,
      html_content_type,
      status
    )
  end

  def component(comp : Lucky::BaseComponent.class, status : HTTP::Status, **named_args) : Lucky::TextResponse
    component(comp, status.value, **named_args)
  end
end
