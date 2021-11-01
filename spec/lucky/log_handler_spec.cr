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
    log_output.should contain(%("method" => "GET"))
    log_output.should contain(%("path" => "/"))
    log_output.should contain(%("status" => 200))
    log_output.should contain(%("duration"))
    called.should be_true
  end

  it "skips logging if skip_if function returns true" do
    Lucky::LogHandler.temp_config(skip_if: ->(_context : HTTP::Server::Context) { true }) do
      called = false
      log_io = IO::Memory.new
      context = build_context_with_io(log_io)

      call_log_handler_with(log_io, context) { called = true }

      log_io.to_s.should eq("")
      called.should be_true
    end
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

  it "publishes the request_complete_event" do
    Lucky::Events::RequestCompleteEvent.subscribe do |event|
      event.duration.should_not be_nil
    end

    called = false
    log_io = IO::Memory.new
    context = build_context_with_io(log_io)

    call_log_handler_with(log_io, context) { called = true }

    called.should be_true
  end
end

private def call_log_handler_with(io : IO, context : HTTP::Server::Context, &block)
  Lucky::Log.dexter.temp_config(io) do
    handler = Lucky::LogHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) { block.call }
    handler.call(context)
  end
end
