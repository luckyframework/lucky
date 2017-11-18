require "../spec_helper"
require "http/server"

include ContextHelper

describe LuckyWeb::LogHandler do
  it "logs" do
    io = IO::Memory.new
    called = false
    log_io = IO::Memory.new
    context = build_context_with_io(io)

    call_log_handler_with(log_io, context) { called = true }

    log_output = log_io.to_s
    log_output.should contain("GET")
    log_output.should contain("200")
    log_output.should contain("/")
    log_output.should_not match(/#{Time.now.to_s("%Y-%m-%d")}/)
    called.should be_true
  end

  it "logs debug messages" do
    io = IO::Memory.new
    log_io = IO::Memory.new
    context = build_context_with_io(io)
    context.add_debug_message("debug this")

    call_log_handler_with(log_io, context) {}

    log_output = log_io.to_s
    log_output.should contain("debug this")
  end

  it "logs errors" do
    io = IO::Memory.new
    context = build_context_with_io(io)
    log_io = IO::Memory.new

    expect_raises(Exception, "Foo") do
      call_log_handler_with(log_io, context) { raise "Foo" }
    end
    log_output = log_io.to_s
    log_output.should contain("GET")
    log_output.should_not match(/#{Time.now.to_s("%Y-%m-%d")}/)
    log_output.should contain("Unhandled exception:")
  end

  context "when configured to log timestamps" do
    it "logs timestamp" do
      begin
        LuckyWeb::LogHandler.configure do
          settings.show_timestamps = true
        end

        io = IO::Memory.new
        called = false
        log_io = IO::Memory.new
        context = build_context_with_io(io)

        call_log_handler_with(log_io, context) { called = true }

        log_output = log_io.to_s
        log_output.should contain("GET")
        log_output.should match(/#{Time.now.to_s("%Y-%m-%d")}/)
        called.should be_true
      ensure
        LuckyWeb::LogHandler.configure do
          settings.show_timestamps = false
        end
      end
    end
  end

  context "when context is configured to be hidden from logs" do
    it "does not log anything" do
      io = IO::Memory.new
      called = false
      log_io = IO::Memory.new
      context = build_context_with_io(io)
      context.hide_from_logs = true

      call_log_handler_with(log_io, context) { called = true }

      log_output = log_io.to_s
      log_output.should eq("")
      called.should be_true
    end
  end
end

private def call_log_handler_with(io : IO, context : HTTP::Server::Context, &block)
  handler = LuckyWeb::LogHandler.new(io)
  handler.next = ->(ctx : HTTP::Server::Context) { block.call }
  handler.call(context)
end
