require "../../spec_helper"

include ContextHelper

describe Lucky::Flash::Handler do
  it "persists only the messages for the next request" do
    context = build_context
    context.flash.now[:just_for_this_request] = "now"
    context.flash[:for_next_request] = "next"

    call_flash_handler_with(context) do |new_context|
      expected_json = {for_next_request: "next"}.to_json
      new_context.session[Lucky::Flash::Handler::PARAM_KEY].should eq(expected_json)
    end
  end
end

private def call_flash_handler_with(context : HTTP::Server::Context)
  handler = Lucky::Flash::Handler.new
  handler.next = ->(_ctx : HTTP::Server::Context) {}
  handler.call(context)
  yield context
end
