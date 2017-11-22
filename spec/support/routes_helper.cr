module RoutesHelper
  private def assert_route_added?(expected_route)
    Lucky::Router.routes.should contain(expected_route)
  end

  private def assert_route_not_added?(expected_route)
    Lucky::Router.routes.should_not contain(expected_route)
  end
end
