require "../spec_helper"

include ContextHelper

describe LuckyWeb::StaticFileHandler do
  it "hides static files from logs" do
    context = build_context
    context.hide_from_logs?.should be_false
    called = false

    call_file_handler_with(context) { called = true }

    called.should be_true
    context.hide_from_logs?.should be_true
  end
end

private def call_file_handler_with(context : HTTP::Server::Context, &block)
  handler = LuckyWeb::StaticFileHandler.new(public_dir: "/foo")
  handler.next = ->(ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
