require "../spec_helper"

class RootAction < Lucky::Action
  get "/" do
    text "Hello there"
  end
end

describe "root helpers" do
  it "renders as /" do
    RootAction.path.should eq "/"
    RootAction.route.path.should eq "/"
  end
end
