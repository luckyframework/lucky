require "../spec_helper"

describe Lucky::Exceptions::InvalidParam do
  it "responds with a custom HTTP code" do
    error = Lucky::Exceptions::InvalidParam.new(
      param_name: "page",
      param_value: "select%201+1",
      param_type: "Int32")
    error.should be_a(Lucky::HttpRespondable)
    error.http_error_code.should eq 422
  end
end
