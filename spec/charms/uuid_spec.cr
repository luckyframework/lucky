require "../spec_helper"

describe "UUID charm" do
  describe "to_parm" do
    it "gets the value as a string" do
      uuid = UUID.new("87b3042b-9b9a-41b7-8b15-a93d3f17025e")
      uuid.to_param.should eq "87b3042b-9b9a-41b7-8b15-a93d3f17025e"
      uuid.to_param.class.should eq String
    end
  end
end
