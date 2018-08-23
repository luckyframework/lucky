require "colorize"
require "./log_formatters/**"

class Lucky::LogHandler
  include HTTP::Handler

  Habitat.create do
    setting show_timestamps : Bool
    setting log_formatter : LogFormatters::Base = DefaultLogFormatter.new
    setting enabled : Bool = true
  end

  def initialize(@io : IO = STDOUT)
  end

  def call(context)
    if settings.enabled
      time = Time.now
      call_next(context)
      elapsed = Time.now - time

      if !context.hide_from_logs?
        log_request(context, time, elapsed)
      end
      {% if !flag?(:release) %}
        log_debug_messages(context)
      {% end %}
    else
      call_next context
    end
  rescue e
    log_exception(context, time, e)
    raise e
  end

  private def log_request(context, time, elapsed)
    @io.puts settings.log_formatter.format(context, time, elapsed)
  end

  private def log_exception(context, time, e)
    @io.puts "#{context.request.method} #{context.request.resource}#{LogHandler.timestamp(time)} - Unhandled exception:"
    e.inspect_with_backtrace(@io)
  end

  private def log_debug_messages(context)
    context.debug_messages.each do |message|
      @io.puts "  #{"▸".colorize(:green)} #{message}"
    end
  end

  def self.timestamp(time)
    if settings.show_timestamps
      " #{Time::Format::ISO_8601_DATE_TIME.format(time || Time.now)}"
    else
      ""
    end
  end
end
