require "../../spec_helper"

include RoutesHelper

class Singular::New < Lucky::Action
  action singular: true do
    text "test"
  end
end

class Singular::Edit < Lucky::Action
  action singular: true do
    text "test"
  end
end

class Singular::Show < Lucky::Action
  action singular: true do
    text "test"
  end
end

class Singular::Delete < Lucky::Action
  action singular: true do
    text "test"
  end
end

class Singular::Update < Lucky::Action
  action singular: true do
    text "test"
  end
end

class Singular::Create < Lucky::Action
  action singular: true do
    text "test"
  end
end

describe Lucky::Action do
  describe "singular routing" do
    it "adds singular routes to the router" do
      assert_route_added? Lucky::Route.new :get, "/singular/new", Singular::New
      assert_route_added? Lucky::Route.new :get, "/singular/edit", Singular::Edit
      assert_route_added? Lucky::Route.new :get, "/singular", Singular::Show
      assert_route_added? Lucky::Route.new :delete, "/singular", Singular::Delete
      assert_route_added? Lucky::Route.new :put, "/singular", Singular::Update
      assert_route_added? Lucky::Route.new :post, "/singular", Singular::Create
    end
  end
end
