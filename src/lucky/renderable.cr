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
  #   route do
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
      "text/html",
      view.perform_render,
      debug_message: log_message(view),
      enable_cookies: enable_cookies?
    )
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

  def plain_text(body : String, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body, "text/plain", status)
  end

  def plain_text(body : String, status : HTTP::Status) : Lucky::TextResponse
    plain_text(body, status: status.value)
  end

  # :nodoc:
  private def text(*args, **named_args)
    {% raise "'text' in actions has been renamed to 'plain_text'" %}
  end

  @[Deprecated("`render_text` deprecated. Use `plain_text` instead")]
  private def render_text(*args, **named_args) : Lucky::TextResponse
    plain_text(*args, **named_args)
  end

  def head(status : Int32) : Lucky::TextResponse
    send_text_response(body: "", content_type: "", status: status)
  end

  def head(status : HTTP::Status) : Lucky::TextResponse
    head(status.value)
  end

  def json(body, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body.to_json, "application/json", status)
  end

  def json(body, status : HTTP::Status) : Lucky::TextResponse
    json(body, status: status.value)
  end

  def xml(body : String, status : Int32? = nil) : Lucky::TextResponse
    send_text_response(body, "text/xml", status)
  end

  def xml(body, status : HTTP::Status) : Lucky::TextResponse
    xml(body, status: status.value)
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
      comp.new(**named_args).render_to_string,
      "text/html",
      status
    )
  end

  def component(comp : Lucky::BaseComponent.class, status : HTTP::Status, **named_args) : Lucky::TextResponse
    component(comp, status.value, **named_args)
  end
end
