module LuckyWeb::Redirectable
  def redirect(to route : LuckyWeb::RouteHelper, status = 302)
    redirect to: route.path, status: status
  end

  def redirect(to action : LuckyWeb::Action.class, status = 302)
    redirect to: action.route, status: status
  end

  def redirect(to path : String, status = 302)
    context.response.headers.add "Location", path
    context.response.headers.add "Turbolinks-Location", path
    context.response.status_code = status
    LuckyWeb::Response.new(context, "", "")
  end
end
