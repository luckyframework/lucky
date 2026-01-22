require "../spec_helper"

# Test action with params for routes JSON output
private class RoutesTaskTestAction < TestAction
  param page : Int32?
  param search : String?

  get "/routes_task_test" do
    plain_text "test"
  end
end

describe Routes do
  describe "Format JSON" do
    it "outputs routes as JSON" do
      task = Routes.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: ["--format=json"])

      output = task.output.to_s
      json = JSON.parse(output)

      json.should be_a(JSON::Any)
      json.as_a.should_not be_empty
    end

    it "includes method, path, action, and params in JSON output" do
      task = Routes.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: ["--with-params", "-f", "json"])

      output = task.output.to_s
      json = JSON.parse(output)
      routes = json.as_a

      # Find our test action in the routes
      test_route = routes.find! { |route| route["action"].as_s == "RoutesTaskTestAction" }

      test_route["method"].as_s.should eq "GET"
      test_route["path"].as_s.should eq "/routes_task_test"
      test_route["action"].as_s.should eq "RoutesTaskTestAction"

      params = test_route["params"].as_a
      params.size.should eq 2

      page_param = params.find! { |param| param["name"].as_s == "page" }
      page_param["type"].as_s.should contain "Int32"

      search_param = params.find! { |param| param["name"].as_s == "search" }
      search_param["type"].as_s.should contain "String"
    end

    it "excludes HEAD routes from JSON output" do
      task = Routes.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: ["--format=json"])

      output = task.output.to_s
      json = JSON.parse(output)
      routes = json.as_a

      head_routes = routes.select { |route| route["method"].as_s == "HEAD" }
      head_routes.should be_empty
    end
  end

  describe "default table output" do
    it "still works without format flag" do
      task = Routes.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: [] of String)

      output = task.output.to_s
      output.should contain "Verb"
      output.should contain "URI"
      output.should contain "Action"
    end
  end
end
