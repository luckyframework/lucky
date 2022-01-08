module RoutesHelper
  private def assert_route_added?(expected_route)
    Lucky.router.routes.should contain(expected_route)
  end

  private def assert_route_not_added?(expected_route)
    Lucky.router.routes.should_not contain(expected_route)
  end
end
