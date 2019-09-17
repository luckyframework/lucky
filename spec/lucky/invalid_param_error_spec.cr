require "../spec_helper"

describe Lucky::InvalidParamError do
  it "responds with a custom HTTP code" do
    error = Lucky::InvalidParamError.new(
      param_name: "page",
      param_value: "select%201+1",
      param_type: "Int32")
    error.should be_a(Lucky::RenderableError)
    error.renderable_message.should contain("couldn't be parsed")
    error.renderable_status.should eq 422
  end
end
