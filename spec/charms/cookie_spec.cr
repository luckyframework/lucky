require "../spec_helper"

describe HTTP::Cookie do
  describe "#domain" do
    it "can chain and set values" do
      time = Time.now
      cookie = test_cookie
        .name("session_id")
        .value("1")
        .path("/cookies")
        .expires(time)
        .domain("luckyframework.org")
        .secure(true)
        .http_only(true)

      cookie.should be_a(HTTP::Cookie)
      cookie.name.should eq("session_id")
      cookie.value.should eq("1")
      cookie.path.should eq("/cookies")
      cookie.expires.should eq(time)
      cookie.domain.should eq("luckyframework.org")
      cookie.secure.should be_true
      cookie.http_only.should be_true
    end
  end
end

private def test_cookie
  HTTP::Cookie.new(name: "name", value: "lucky")
end
