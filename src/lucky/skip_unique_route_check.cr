# Include this in an action to skip route uniqueness checks.
module Lucky::SkipUniqueRouteCheck
  macro enforce_route_uniqueness(*args, **named_args)
    # no-op
  end
end
