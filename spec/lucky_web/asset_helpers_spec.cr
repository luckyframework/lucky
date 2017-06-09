require "../spec_helper"

private class TestPage < LuckyWeb::Page
  include LuckyWeb::AssetHelpers

  def render
    asset("images/logo.png")
  end
end

describe LuckyWeb::AssetHelpers do
  it "returns the fingerprinted path" do
    LuckyWeb::AssetHelpers.asset("images/logo.png").should eq "images/logo-with-hash.png"
  end

  it "works when included in another class" do
    TestPage.new.render.should eq "images/logo-with-hash.png"
  end
end
