abstract class Lucky::LogFormatters::Base
  abstract def format(context, time, elapsed) : String

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

  private def timestamp(time)
    if Lucky::LogHandler.settings.show_timestamps
      " #{Time::Format::ISO_8601_DATE_TIME.format(time || Time.now)}"
    else
      ""
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
end
