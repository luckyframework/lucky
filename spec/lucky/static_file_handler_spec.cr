require "../spec_helper"

include ContextHelper

describe Lucky::StaticFileHandler do
  it "shows static files in logs" do
    context = build_context
    called = false

    call_file_handler_with(context) { called = true }

    called.should be_true
  end
end

private def call_file_handler_with(context : HTTP::Server::Context, &block)
  handler = Lucky::StaticFileHandler.new(public_dir: "/foo")
  handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
