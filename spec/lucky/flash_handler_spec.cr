require "../spec_helper"

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
    now_json = {success: "Yay!"}.to_json
    context1.session.set(Lucky::FlashStore::SESSION_KEY, now_json)
    next_json = context1.flash.to_json

    context1.flash.success.should eq("Yay!")

    Lucky::FlashHandler.new.call(context1)

    context2 = build_context
    context2.session.set(Lucky::FlashStore::SESSION_KEY, next_json)

    context2.flash.success.should eq("")
  end

  it "keeps the flash for the next request" do
    context1 = build_context
    context1.flash.success = "Yay!"
    next_json = context1.flash.to_json

    Lucky::FlashHandler.new.call(context1)

    context2 = build_context
    context2.session.set(Lucky::FlashStore::SESSION_KEY, next_json)

    context2.flash.success.should eq("Yay!")
  end
end
