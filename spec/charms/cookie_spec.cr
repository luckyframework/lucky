require "../spec_helper"

describe HTTP::Cookie do
  describe "setters" do
    it "can chain and set values" do
      time = Time.utc
      cookie = test_cookie
        .name("session_id")
        .value("1")
        .path("/cookies")
        .expires(time)
        .domain("luckyframework.org")
        .secure(true)
        .http_only(true)
        .samesite(:lax)

      cookie.should be_a(HTTP::Cookie)
      cookie.name.should eq("session_id")
      cookie.value.should eq("1")
      cookie.path.should eq("/cookies")
      cookie.expires.should eq(time)
      cookie.domain.should eq("luckyframework.org")
      cookie.secure.should be_true
      cookie.http_only.should be_true
      cookie.samesite.to_s.should eq "Lax"
    end
  end

  describe "#permanent" do
    it "sets expiration 20 years from now" do
      cookie = test_cookie.permanent

      cookie.expires.as(Time).should be_close(20.years.from_now, 1.minute)
    end
  end
end

private def test_cookie
  HTTP::Cookie.new(name: "name", value: "lucky")
end
