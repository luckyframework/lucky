require "../../spec_helper"

include ContextHelper

describe Lucky::FlashHandler do
  it "writes the flash to the session" do
    context = build_context
    context.flash.success = "Yay!"
    flash_json = {success: "Yay!"}.to_json

    Lucky::FlashHandler.new.call(context)

    context.session.get(Lucky::FlashStore::SESSION_KEY).should eq(flash_json)
  end

  it "only keeps the flash for one request" do
    context1 = build_context
    first_json = {success: "Yay!"}.to_json
    context1.session.set(Lucky::FlashStore::SESSION_KEY, first_json)

    context1.flash.success.should eq("Yay!")

    Lucky::FlashHandler.new.call(context1)

    next_json = context1.session.get(Lucky::FlashStore::SESSION_KEY)
    context2 = build_context
    context2.session.set(Lucky::FlashStore::SESSION_KEY, next_json)

    context2.flash.success.should eq("")
  end
end
