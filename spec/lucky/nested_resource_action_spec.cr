require "../spec_helper"

class Projects::Tasks::Show < TestAction
  nested_route do
    plain_text "plain"
  end
end

class Admin::Projects::Tasks::Show < TestAction
  nested_route do
    plain_text "plain"
  end
end

describe Lucky::Action do
  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Projects::Tasks::Show
        .path("project_id", "task_id")
        .should eq "/projects/project_id/tasks/task_id"
      Projects::Tasks::Show
        .with("project_id", "task_id")
        .should eq Lucky::RouteHelper.new(:get, "/projects/project_id/tasks/task_id")
      Admin::Projects::Tasks::Show
        .path("project_id", "task_id")
        .should eq "/admin/projects/project_id/tasks/task_id"
      Admin::Projects::Tasks::Show
        .with("project_id", "task_id")
        .should eq Lucky::RouteHelper.new(:get, "/admin/projects/project_id/tasks/task_id")
    end

    it "adds routes to the router" do
      assert_route_added? Lucky::Route.new :get, "/projects/:project_id/tasks/:task_id", Projects::Tasks::Show
      assert_route_added? Lucky::Route.new :get, "/admin/projects/:project_id/tasks/:task_id", Admin::Projects::Tasks::Show
    end
  end
end

private def assert_route_added?(expected_route)
  Lucky::Router.routes.should contain(expected_route)
end
