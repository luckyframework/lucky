require "../spec_helper"

private class TestJSON < LuckyWeb::Serializer
  def initialize(@user_name : String)
  end

  def render
    {name: @user_name}
  end
end

private class TestNestedJSON < LuckyWeb::Serializer
  def initialize(@user_name : String)
  end

  def render
    {user: TestJSON.new(@user_name)}
  end
end

describe LuckyWeb::Serializer do
  describe "#to_json" do
    it "calls to_json on the render data" do
      TestJSON.new(user_name: "Rey").to_json.should eq({name: "Rey"}.to_json)
    end

    it "handles nested JSON classes" do
      nested = TestNestedJSON.new(user_name: "Picard")
      nested.to_json.should eq({user: {name: "Picard"}}.to_json)
    end
  end
end
