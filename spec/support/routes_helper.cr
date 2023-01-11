module RoutesHelper
  private def assert_route_added?(method, path, expected_action)
    result = Lucky.router.find_action(method, path)
    result.should_not be_nil
    result.as(LuckyRouter::Match).payload.should eq expected_action
  end

  private def assert_route_not_added?(method, path)
    result = Lucky.router.find_action(method, path)
    result.should be_nil
  end
end
