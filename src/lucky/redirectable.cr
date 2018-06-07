# Redirect the browser
#
# There are multiple ways to redirect inside of an action. The most common ways are to redirect to a `Lucky::Action` class, or a URL/path `String`. Both use the `redirect` method:
#
# ```crystal
# redirect to: Users::Index
# redirect to: "https://luckyframework.org/"
# redirect to: "/users"
# ```
#
# By default, the method will set the status code to `302` A.K.A. "Found". If you want to customize the status code, you can pass it directly:
#
# ```crystal
# # create a user
# redirect to: Users::Index, status: 201
#
# # or use the built in enum value
# redirect to: Users::Index, status: Status::Created
# ```
#
# Internally, all the different methods in this module eventually use the method that takes a `String`. However, it's recommended you pass a `Lucky::Action` class if possible because it guarentees runtime safety.
module Lucky::Redirectable
  # Redirect using a `Lucky::RouteHelper`
  def redirect(to route : Lucky::RouteHelper, status = 302)
    redirect to: route.path, status: status
  end

  # Redirect using a `Lucky::Action`
  def redirect(to action : Lucky::Action.class, status = 302)
    redirect to: action.route, status: status
  end

  # Redirect using a `String`
  def redirect(to path : String, status = 302)
    context.response.headers.add "Location", path
    context.response.headers.add "Turbolinks-Location", path
    context.response.status_code = status
    Lucky::Response.new(context, "", "")
  end

  # Redirect using a `String` and a `Status` value
  def redirect(to path : String, status : Lucky::Action::Status = Lucky::Action::Status::Found)
    redirect(path, status.value)
  end
end
