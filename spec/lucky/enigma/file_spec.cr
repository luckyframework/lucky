require "../../spec_helper"

describe "Enigma::File" do
  it "encrypts" do
    contents = Enigma::File.new("my-string", key: "123abc").encrypt

    contents.should eq %(U2FsdGVkX1/tauNboD98GxCNpe+xstYioqLwxgHYkeM=)
  end

  it "decrypt" do
    contents = Enigma::File.new(
      %(U2FsdGVkX1/tauNboD98GxCNpe+xstYioqLwxgHYkeM=),
      key: "123abc"
    ).decrypt

    contents.should eq "my-string"
  end
end
