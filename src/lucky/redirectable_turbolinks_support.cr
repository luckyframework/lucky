# Set "Turbo-Location" from session
# Needs to change browser address bar at last request
#
# This pipe extracted Lucky::Redirectable, because Lucky::Redirectable included to Lucky::ErrorAction
# but Lucky::ErrorAction not have pipe support
module Lucky::RedirectableTurboSupport
  macro included
    before set_turbo_location_header_from_session
  end

  private def set_turbo_location_header_from_session
    if turbo_location = cookies.get?(:_turbo_location)
      cookies.delete(:_turbo_location)
      # change browser address bar at last request
      response.headers["Turbo-Location"] = turbo_location
    end
    continue
  end
end
