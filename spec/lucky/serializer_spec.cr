require "../spec_helper"

private class TestJSON < Lucky::Serializer
  def initialize(@user_name : String)
  end

  def render
    {name: @user_name}
  end
end

private class TestNestedJSON < Lucky::Serializer
  def initialize(@user_name : String)
  end

  def render
    {user: TestJSON.new(@user_name)}
  end
end

private class TestUuidJSON < Lucky::Serializer
  def initialize(@id : UUID)
  end

  def render
    {id: @id}
  end
end

describe Lucky::Serializer do
  describe "#to_json" do
    it "calls to_json on the render data" do
      TestJSON.new(user_name: "Rey").to_json.should eq({name: "Rey"}.to_json)
    end

    it "handles nested JSON classes" do
      nested = TestNestedJSON.new(user_name: "Picard")
      nested.to_json.should eq({user: {name: "Picard"}}.to_json)
    end

    it "handles UUIds without user's having to include uuid/json manually" do
      id = UUID.new("87b3042b-9b9a-41b7-8b15-a93d3f17025e")
      TestUuidJSON.new(id).to_json.should eq({id: id.to_s}.to_json)
    end
  end
end
