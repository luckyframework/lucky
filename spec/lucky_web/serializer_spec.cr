require "../spec_helper"

private class TestJSON < LuckyWeb::Serializer
  def initialize(@user_name : String)
  end

  def render
    {name: @user_name}
  end
end

describe LuckyWeb::Serializer do
  describe "#to_json" do
    it "calls to_json on the render data" do
      user = TestJSON.new(user_name: "Rey")

      user.to_json.should eq({name: "Rey"}.to_json)
    end
  end
end
