# Set "Turbolinks-Location" from session
# Needs to change browser address bar at last request, see https://github.com/turbolinks/turbolinks#following-redirects
#
# This pipe extracted Lucky::Redirectable, because Lucky::Redirectable included to Lucky::ErrorAction
# but Lucky::ErrorAction not have pipe support
module Lucky::RedirectableTurbolinksSupport
  # Overrides Lucky::Redirectable redirect's method
  def redirect(to path : String, status : Int32 = 302) : Lucky::TextResponse
    # flash messages are not consumed here, so keep them for the next action
    flash.keep
    if ajax? && request.method != "GET"
      context.response.headers.add "Location", path

      # do not enable form disabled elements for XHR redirects, see https://github.com/rails/rails/pull/31441
      context.response.headers.add "X-Xhr-Redirect", path

      Lucky::TextResponse.new(context,
        "text/javascript",
        %[Turbolinks.clearCache();\nTurbolinks.visit(#{path.to_json}, {"action": "replace"})],
        status: 200)
    else
      if request.headers["Turbolinks-Referrer"]?
        store_turbolinks_location_in_session(path)
      end
      # ordinary redirect
      context.response.headers.add "Location", path
      context.response.status_code = status
      Lucky::TextResponse.new(context, "", "")
    end
  end

  private def store_turbolinks_location_in_session(path : String)
    cookies.set(:_turbolinks_location, path).http_only(true)
  end

  macro included
    before set_turbolinks_location_header_from_session
  end

  private def set_turbolinks_location_header_from_session
    if turbolinks_location = cookies.get?(:_turbolinks_location)
      cookies.delete(:_turbolinks_location)
      # change browser address bar at last request, see https://github.com/turbolinks/turbolinks#following-redirects
      response.headers["Turbolinks-Location"] = turbolinks_location
    end
    continue
  end
end
