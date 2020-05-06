# Set "Turbolinks-Location" from session
# Needs to change browser address bar at last request, see https://github.com/turbolinks/turbolinks#following-redirects
#
# This pipe extracted Lucky::Redirectable, because Lucky::Redirectable included to Lucky::ErrorAction
# but Lucky::ErrorAction not have pipe support
module Lucky::RedirectableTurbolinksSupport
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
