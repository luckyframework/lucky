require "../spec_helper"

include ContextHelper

describe LuckyWeb::StaticFileHandler do
  it "hides static files from logs" do
    begin
      LuckyWeb::StaticFileHandler.configure { settings.hide_from_logs = true }
      context = build_context
      context.hide_from_logs?.should be_false
      called = false

      call_file_handler_with(context) { called = true }

      called.should be_true
      context.hide_from_logs?.should be_true
    ensure
      LuckyWeb::StaticFileHandler.configure { settings.hide_from_logs = true }
    end
  end

  it "shows static files in logs" do
    begin
      LuckyWeb::StaticFileHandler.configure { settings.hide_from_logs = false }
      context = build_context
      context.hide_from_logs?.should be_false
      called = false

      call_file_handler_with(context) { called = true }

      called.should be_true
      context.hide_from_logs?.should be_false
    ensure
      LuckyWeb::StaticFileHandler.configure { settings.hide_from_logs = true }
    end
  end
end

private def call_file_handler_with(context : HTTP::Server::Context, &block)
  handler = LuckyWeb::StaticFileHandler.new(public_dir: "/foo")
  handler.next = ->(ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
