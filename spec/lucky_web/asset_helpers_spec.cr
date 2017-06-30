require "../spec_helper"

private class TestPage
  include LuckyWeb::AssetHelpers

  def asset_url
    asset("images/logo.png")
  end
end

describe LuckyWeb::AssetHelpers do
  it "returns the fingerprinted path" do
    LuckyWeb::AssetHelpers.asset("images/logo.png").should eq "/images/logo-with-hash.png"
  end

  it "works when included in another class" do
    TestPage.new.asset_url.should eq "/images/logo-with-hash.png"
  end
end
