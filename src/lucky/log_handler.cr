require "colorize"

class Lucky::LogHandler
  include HTTP::Handler

  Habitat.create do
    setting show_timestamps : Bool
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
    @io.puts "#{context.request.method} #{colored_status_code(context.response.status_code)} #{context.request.resource}#{timestamp(time)} (#{elapsed_text(elapsed)})"
  end

  private def log_exception(context, time, e)
    @io.puts "#{context.request.method} #{context.request.resource}#{timestamp(time)} - Unhandled exception:"
    e.inspect_with_backtrace(@io)
  end

  private def colored_status_code(status_code)
    case status_code
    when 200..399
      "#{status_code.colorize(:green)}"
    when 400..499
      "#{status_code.colorize(:yellow)}"
    when 500..599
      "#{status_code.colorize(:red)}"
    else
      "#{status_code}"
    end
  end

  private def log_debug_messages(context)
    context.debug_messages.each do |message|
      @io.puts "  #{"▸".colorize(:green)} #{message}"
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
    if settings.show_timestamps
      " #{Time::Format::ISO_8601_DATE_TIME.format(time || Time.now)}"
    else
      ""
    end
  end
end
