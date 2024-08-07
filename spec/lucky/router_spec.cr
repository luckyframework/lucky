require "../spec_helper"

describe Lucky::Router do
  it "routes based on the method name and path" do
    Lucky.router.add :get, "/router-test1", Lucky::Action

    Lucky.router.find_action(:get, "/router-test1").should_not be_nil
    Lucky.router.find_action("get", "/router-test1").should_not be_nil
    Lucky.router.find_action(:post, "/router-test1").should be_nil
  end

  it "finds the associated get route by a head method" do
    Lucky.router.add :get, "/router-test2", Lucky::Action

    Lucky.router.find_action(:head, "/router-test2").should_not be_nil
    Lucky.router.find_action("head", "/router-test2").should_not be_nil
  end

  it "finds the route with an optional parts" do
    Lucky.router.add :get, "/complex_path/:required/?:optional_a/?:optional_b", Lucky::Action

    Lucky.router.find_action(:get, "/complex_path/1/2/3").should_not be_nil
    Lucky.router.find_action(:get, "/complex_path/1/2").should_not be_nil
    Lucky.router.find_action(:get, "/complex_path/1").should_not be_nil
  end

  describe "#list_routes" do
    it "returns list of routes" do
      Lucky.router.add :get, "/users", Lucky::Action
      Lucky.router.add :put, "/clients/:client_id", Lucky::Action

      routes = Lucky.router.list_routes

      routes.should contain({"/users", "get", Lucky::Action})
      routes.should contain({"/clients/:client_id", "put", Lucky::Action})
    end
  end
end
