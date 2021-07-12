# Include this in an action to skip any style checks on routes
module Lucky::SkipRouteStyleCheck
  macro enforce_route_style(*args, **named_args)
    # no-op
  end
end
