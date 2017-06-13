require "../../spec_helper"

class Projects::Tasks::Show < LuckyWeb::Action
  nested_action do
    render_text "plain"
  end
end

class Admin::Projects::Tasks::Show < LuckyWeb::Action
  nested_action do
    render_text "plain"
  end
end

describe LuckyWeb::Action do
  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Projects::Tasks::Show
        .path("project_id", "task_id")
        .should eq "/projects/project_id/tasks/task_id"
      Projects::Tasks::Show
        .route("project_id", "task_id")
        .should eq LuckyWeb::RouteHelper.new(:get, "/projects/project_id/tasks/task_id")
      Admin::Projects::Tasks::Show
        .path("project_id", "task_id")
        .should eq "/admin/projects/project_id/tasks/task_id"
      Admin::Projects::Tasks::Show
        .route("project_id", "task_id")
        .should eq LuckyWeb::RouteHelper.new(:get, "/admin/projects/project_id/tasks/task_id")
    end

    it "adds routes to the router" do
      assert_route_added? LuckyWeb::Route.new :get, "/projects/:project_id/tasks/:id", Projects::Tasks::Show
      assert_route_added? LuckyWeb::Route.new :get, "/admin/projects/:project_id/tasks/:id", Admin::Projects::Tasks::Show
    end
  end
end

private def assert_route_added?(expected_route)
  LuckyWeb::Router.routes.should contain(expected_route)
end
