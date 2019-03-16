# Redirect the request
#
# There are multiple ways to redirect inside of an action. The most common ways are to redirect to a `Lucky::Action` class, or a URL/path `String`. Both use the `redirect` method:
#
# ```crystal
# redirect to: Users::Index
# redirect to: Users::Show.with(user.id)
# redirect to: "https://luckyframework.org/"
# redirect to: "/users"
# ```
#
# By default, the method will set the status code to `302` A.K.A. "Found". If you want to customize the status code, you can pass it directly:
#
# ```crystal
# redirect to: Users::Index, status: 301
#
# # or use the built in enum value
# redirect to: Users::Index, status: Status::MovedPermanently
# ```
#
# You can find a list of all of the possible statuses [here](https://github.com/luckyframework/lucky/blob/master/src/lucky/action.cr).
#
# Internally, all the different methods in this module eventually use the
# method that takes a `String`. However, it's recommended you pass a
# `Lucky::Action` class if possible because it guarantees runtime safety.
module Lucky::Redirectable
  # Redirect using a `Lucky::RouteHelper`
  #
  # ```crystal
  # redirect to: Users::Show.with(user.id), status: 301
  # ```
  def redirect(to route : Lucky::RouteHelper, status = 302) : Lucky::TextResponse
    redirect to: route.path, status: status
  end

  # Redirect to a `Lucky::Action`
  #
  # ```crystal
  # redirect to: Users::Index
  # ```
  def redirect(to action : Lucky::Action.class, status = 302) : Lucky::TextResponse
    redirect to: action.route, status: status
  end

  # Redirect using a `String` and a `Status` value
  #
  # ```crystal
  # redirect to: "/users", status: Status::MovedPermanently
  # ```
  # You can find a list of all of the possible statuses [here](https://github.com/luckyframework/lucky/blob/master/src/lucky/action.cr).
  def redirect(to path : String, status : Lucky::Action::Status = Lucky::Action::Status::Found) : Lucky::TextResponse
    redirect(path, status.value)
  end

  # Redirect using a `String`
  #
  # ```crystal
  # redirect to: "/users"
  # redirect to: "/users/1", status: 301
  # ```
  def redirect(to path : String, status : Int32 = 302) : Lucky::TextResponse
    context.response.headers.add "Location", path
    context.response.headers.add "Turbolinks-Location", path
    context.response.status_code = status
    Lucky::TextResponse.new(context, "", "")
  end

  # :nodoc:
  def redirect(to page_instead_of_action : Lucky::HTMLPage.class, **unused_args)
    {% raise "You accidentally redirected to a Lucky::HTMLPage instead of a Lucky::Action" %}
  end
end
