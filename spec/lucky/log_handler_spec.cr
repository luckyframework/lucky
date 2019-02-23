require "../spec_helper"
require "http/server"

include ContextHelper

describe Lucky::LogHandler do
  it "logs the start and end of the request" do
    called = false
    log_io = IO::Memory.new
    context = build_context_with_io(log_io)

    call_log_handler_with(log_io, context) { called = true }

    log_output = log_io.to_s
    log_output.should contain("GET #{"/".colorize.underline}")
    log_output.should contain("Sent #{"200".colorize.green}")
    called.should be_true
  end

  it "logs errors" do
    log_io = IO::Memory.new
    context = build_context_with_io(log_io)

    expect_raises(Exception, "an error") do
      call_log_handler_with(log_io, context) { raise "an error" }
    end
    log_output = log_io.to_s
    log_output.should contain("an error")
  end

  context "when context is configured to be hidden from logs" do
    it "does not log anything" do
      called = false
      log_io = IO::Memory.new
      context = build_context_with_io(log_io)
      context.hide_from_logs = true

      call_log_handler_with(log_io, context) { called = true }

      log_output = log_io.to_s
      log_output.should eq("")
      called.should be_true
    end
  end
end

private def call_log_handler_with(io : IO, context : HTTP::Server::Context, &block)
  Lucky::LogHandler.temp_config(logger: Lucky::Logger.new(io)) do
    handler = Lucky::LogHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
    handler.call(context)
  end
end
