# Redirect the request
#
# There are multiple ways to redirect inside of an action. The most common ways are to redirect to a `Lucky::Action` class, or a URL/path `String`. Both use the `redirect` method:
#
# ```
# redirect to: Users::Index
# redirect to: Users::Show.with(user.id)
# redirect to: "https://luckyframework.org/"
# redirect to: "/users"
# ```
#
# By default, the method will set the status code to `302` A.K.A. "Found". If you want to customize the status code, you can pass it directly:
#
# ```
# redirect to: Users::Index, status: 301
#
# # or use the built in enum value
# redirect to: Users::Index, status: :moved_permanently
# ```
#
# You can find a list of all of the possible statuses [here](https://crystal-lang.org/api/latest/HTTP/Status.html).
#
# Internally, all the different methods in this module eventually use the
# method that takes a `String`. However, it's recommended you pass a
# `Lucky::Action` class if possible because it guarantees runtime safety.
module Lucky::Redirectable
  # Redirect back with a `Lucky::Action` fallback
  #
  # ```
  # redirect_back fallback: Users::Index
  # ```
  def redirect_back(*, fallback : Lucky::Action.class, status = 302, allow_external = false)
    redirect_back fallback: fallback.route, status: status, allow_external: allow_external
  end

  # Redirect back with a `Lucky::RouteHelper` fallback
  #
  # ```
  # redirect_back fallback: Users::Show.with(user.id)
  # ```
  def redirect_back(*, fallback : Lucky::RouteHelper, status = 302, allow_external = false)
    redirect_back fallback: fallback.path, status: status, allow_external: allow_external
  end

  # Redirect back with a human friendly status
  #
  # ```
  # redirect_back fallback: "/users", status: HTTP::Status::MOVED_PERMANENTLY
  # ```
  def redirect_back(*, fallback : String, status : HTTP::Status, allow_external = false)
    redirect_back fallback: fallback, status: status.value, allow_external: allow_external
  end

  # Redirects the browser to the page that issued the request (the referrer)
  # if possible, otherwise redirects to the provided default fallback
  # location.
  #
  # The referrer information is pulled from the 'Referer' header on
  # the request. This is an optional header, and if the request
  # is missing this header the *fallback* will be used.
  #
  # ```
  # redirect_back fallback: "/users"
  # ```
  #
  # A redirect status can be specified
  #
  # ```
  # redirect_back fallback: "/home", status: 301
  # ```
  #
  # External referers are ignored by default.
  # It is determined by comparing the referer header to the request host.
  # They can be explicitly allowed if necessary
  #
  # redirect_back fallback: "/home", allow_external: true
  def redirect_back(*, fallback : String, status : Int32 = 302, allow_external : Bool = false)
    referer = request.headers["Referer"]?

    if referer && (allow_external || allowed_host?(referer))
      redirect to: referer, status: status
    else
      redirect to: fallback, status: status
    end
  end

  # Redirect using a `Lucky::RouteHelper`
  #
  # ```
  # redirect to: Users::Show.with(user.id), status: 301
  # ```
  def redirect(to route : Lucky::RouteHelper, status = 302) : Lucky::TextResponse
    redirect to: route.path, status: status
  end

  # Redirect to a `Lucky::Action`
  #
  # ```
  # redirect to: Users::Index
  # ```
  def redirect(to action : Lucky::Action.class, status = 302) : Lucky::TextResponse
    redirect to: action.route, status: status
  end

  # Redirect to the given path, with a human friendly status
  #
  # ```
  # redirect to: "/users", status: :moved_permanently
  # ```
  def redirect(to path : String, status : HTTP::Status) : Lucky::TextResponse
    redirect(path, status.value)
  end

  # Redirect to the given path, with an optional `Int32` status
  #
  # ```
  # redirect to: "/users"
  # redirect to: "/users/1", status: 301
  # ```
  # Note: It's recommended to use the method above that accepts a human friendly version of the status
  def redirect(to path : String, status : Int32 = 302) : Lucky::TextResponse
    # flash messages are not consumed here, so keep them for the next action
    flash.keep
    context.response.headers.add "Location", path
    context.response.status_code = status
    Lucky::TextResponse.new(context, "", "")
  end

  # :nodoc:
  def redirect(to page_instead_of_action : Lucky::HTMLPage.class, **unused_args)
    {% raise "You accidentally redirected to a Lucky::HTMLPage instead of a Lucky::Action" %}
  end

  private def allowed_host?(referer : String) : Bool
    if referer_host = URI.parse(referer).hostname
      referer_host == request.hostname
    else
      false
    end
  end
end
