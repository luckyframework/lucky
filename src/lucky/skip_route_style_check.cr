# Include this in an action to skip any style checks on routes
module Lucky::SkipRouteStyleCheck
  macro enforce_route_style(path, action)
    # no-op
  end
end
