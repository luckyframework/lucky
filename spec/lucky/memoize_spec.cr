require "../spec_helper"

include ContextHelper

private class ObjectWithMemoizedMethods
  include Lucky::Memoizable
  getter times_method_1_called = 0
  getter times_method_2_called = 0

  memoize def method_1 : String
    @times_method_1_called += 1
    "method_1"
  end

  memoize def method_2 : Int32
    @times_method_2_called += 1
    5
  end
end

describe "memoizations" do
  it "only calls the long_task once" do
    object = ObjectWithMemoizedMethods.new

    object.method_1.should eq "method_1"
    2.times { object.method_1 }
    object.times_method_1_called.should eq 1

    object.method_2.should eq 5
    9.times { object.method_2 }
    object.times_method_2_called.should eq 1
  end
end
