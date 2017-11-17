require "../spec_helper"

describe "Hash charm" do
  describe "get" do
    it "gets the string key whether you pass a symbol or string" do
      hash = {"foo" => "bar"}

      hash.get(:foo).should eq "bar"
      hash.get("foo").should eq "bar"
    end

    it "returns nil if the key is missing" do
      hash = {"foo" => "bar"}

      hash.get(:missing).should be_nil
      hash.get("missing").should be_nil
    end
  end

  describe "get!" do
    it "gets the string key whether you pass a symbol or string" do
      hash = {"foo" => "bar"}

      hash.get!(:foo).should eq "bar"
      hash.get!("foo").should eq "bar"
    end

    it "raises KeyError if the key is missing" do
      hash = {"foo" => "bar"}

      expect_raises(KeyError) do
        hash.get!(:missing)
      end
      expect_raises(KeyError) do
        hash.get!("missing")
      end
    end
  end
end
