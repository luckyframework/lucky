module Lucky::Redirectable
  def redirect(to route : Lucky::RouteHelper, status = 302)
    redirect to: route.path, status: status
  end

  def redirect(to action : Lucky::Action.class, status = 302)
    redirect to: action.route, status: status
  end

  def redirect(to path : String, status = 302)
    context.response.headers.add "Location", path
    context.response.headers.add "Turbolinks-Location", path
    context.response.status_code = status
    Lucky::Response.new(context, "", "")
  end

  def redirect(to path : String, status : Lucky::Action::Status = Lucky::Action::Status::Found)
    redirect(path, status.value)
  end
end
