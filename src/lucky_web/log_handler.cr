require "colorize"

class LuckyWeb::LogHandler
  include HTTP::Handler

  Habitat.create do
    setting show_timestamps : Bool
  end

  def initialize(@io : IO = STDOUT)
  end

  def call(context)
    time = Time.now
    call_next(context)
    elapsed = Time.now - time
    elapsed_text = elapsed_text(elapsed)

    @io.puts "#{context.request.method} #{context.response.status_code} #{context.request.resource.colorize(:green)}#{timestamp(time)} (#{elapsed_text})"
    {% if !flag?(:release) %}
      log_debug_messages(context)
    {% end %}
  rescue e
    @io.puts "#{context.request.method} #{context.request.resource}#{timestamp(time)} - Unhandled exception:"
    e.inspect_with_backtrace(@io)
    raise e
  end

  private def log_debug_messages(context)
    context.debug_messages.each do |message|
      @io.puts "  #{"▸".colorize(:cyan)} #{message}"
    end
  end

  private def elapsed_text(elapsed)
    minutes = elapsed.total_minutes
    return "#{minutes.round(2)}m" if minutes >= 1

    seconds = elapsed.total_seconds
    return "#{seconds.round(2)}s" if seconds >= 1

    millis = elapsed.total_milliseconds
    return "#{millis.round(2)}ms" if millis >= 1

    "#{(millis * 1000).round(2)}µs"
  end

  private def timestamp(time)
    if settings.show_timestamps && time
      " #{Time::Format::ISO_8601_DATE_TIME.format(time)}"
    else
      ""
    end
  end
end
