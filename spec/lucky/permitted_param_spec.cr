require "../spec_helper"

describe Lucky::PermittedParam do
  it "sets the proper name and value" do
    param = Lucky::PermittedParam(String).new(name: "name", value: "Gamora")
    param.name.should eq("name")
    param.value.should eq("Gamora")

    param = Lucky::PermittedParam(Array(Int32)).new(name: "deposits", value: [1, 5, 3, 99])
    param.name.should eq("deposits")
    param.value.should eq([1, 5, 3, 99])
  end

  it "sets the param_name with the name and param_key" do
    param = Lucky::PermittedParam(Bool).new(name: "unlocked", value: true, param_key: "code")
    param.param_key.should eq("code")
    param.name.should eq("unlocked")
    param.param_name.should eq("code:unlocked")

    param = Lucky::PermittedParam(Array(Float64)).new(name: "points", value: [0.1, 0.4, 1.2], param_key: "code")
    param.param_key.should eq("code")
    param.name.should eq("points")
    param.param_name.should eq("code:points[]")
  end
end
