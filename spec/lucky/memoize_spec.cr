require "../spec_helper"

include ContextHelper

# NOTE: The Memoizable module is included in the Object charm
# which gives all Objects access to `memoize`
private class ObjectWithMemoizedMethods
  getter times_method_1_called = 0
  getter times_method_2_called = 0
  getter times_method_3_called = 0

  memoize def method_1 : String
    @times_method_1_called += 1
    "method_1"
  end

  memoize def method_2 : Int32?
    @times_method_2_called += 1
    nil
  end

  memoize def method_3(arg_a : String, arg_b : String = "default-arg-b") : String
    @times_method_3_called += 1
    arg_a + ", " + arg_b
  end
end

describe "memoizations" do
  it "only calls the method body once" do
    object = ObjectWithMemoizedMethods.new

    object.method_1.should eq "method_1"
    2.times { object.method_1.should eq("method_1") }
    object.times_method_1_called.should eq 1
  end

  it "can cache a nil result" do
    object = ObjectWithMemoizedMethods.new

    object.method_2.should be_nil
    2.times { object.method_2.should be_nil }
    object.times_method_2_called.should eq 1
  end

  it "caches based on argument equality" do
    object = ObjectWithMemoizedMethods.new

    object.method_3("arg-a", "arg-b").should eq("arg-a, arg-b")
    2.times { object.method_3("arg-a", "arg-b").should eq("arg-a, arg-b") }
    object.times_method_3_called.should eq 1

    object.method_3("arg-a", "arg-c").should eq("arg-a, arg-c")
    2.times { object.method_3("arg-a", "arg-c").should eq("arg-a, arg-c") }
    object.times_method_3_called.should eq 2
  end

  it "handles default arguments" do
    object = ObjectWithMemoizedMethods.new

    object.method_3("arg-a", "default-arg-b").should eq("arg-a, default-arg-b")
    object.method_3("arg-a", "default-arg-b").should eq("arg-a, default-arg-b")
    object.method_3("arg-a").should eq("arg-a, default-arg-b")
    object.times_method_3_called.should eq 1
  end

  it "handles calling with named arguments" do
    object = ObjectWithMemoizedMethods.new

    object.method_3("arg-a", "arg-b").should eq("arg-a, arg-b")
    object.method_3("arg-a", arg_b: "arg-b").should eq("arg-a, arg-b")
    object.method_3(arg_a: "arg-a", arg_b: "arg-b").should eq("arg-a, arg-b")
    object.method_3(arg_b: "arg-b", arg_a: "arg-a").should eq("arg-a, arg-b")
    object.times_method_3_called.should eq 1
  end

  it "does not hold on to result of previous calls" do
    object = ObjectWithMemoizedMethods.new

    object.method_3("arg-a", "arg-b").should eq("arg-a, arg-b")
    object.method_3("arg-a", "arg-c").should eq("arg-a, arg-c")
    object.method_3("arg-a", "arg-b").should eq("arg-a, arg-b")
    object.times_method_3_called.should eq 3
  end
end
