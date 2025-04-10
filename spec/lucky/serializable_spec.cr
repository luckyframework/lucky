require "../spec_helper"

private abstract struct BaseSerializerStruct
  include Lucky::Serializable
end

private struct FoodSerializer < BaseSerializerStruct
  def initialize(@name : String)
  end

  def render
    {name: @name}
  end
end

private abstract class BaseSerializerClass
  include Lucky::Serializable
end

private class DrinksSerializer < BaseSerializerClass
  def initialize(@name : String)
  end

  def render
    {name: @name}
  end
end

describe Lucky::Serializable do
  context "with structs" do
    describe "#to_json" do
      it "calls to_json on the render data" do
        FoodSerializer.new("tacos").to_json.should eq(%({"name":"tacos"}))
      end
    end
  end

  context "with classes" do
    describe "#to_json" do
      it "calls to_json on the render data" do
        DrinksSerializer.new("water").to_json.should eq(%({"name":"water"}))
      end
    end
  end
end
