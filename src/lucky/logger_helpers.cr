module Lucky::LoggerHelpers
  def self.colored_http_status(status_code : Int32) : String
    http_status = HTTP::Status.from_value?(status_code)
    status_name = http_status.try(&.description) || ""
    message = "#{status_code} #{status_name}".colorize.bold

    case status_code
    when 400..499
      message.yellow
    when 500..599
      message.red
    else
      message
    end.to_s
  end

  def self.elapsed_text(elapsed : Time::Span) : String
    minutes = elapsed.total_minutes
    return "#{minutes.round(2)}m" if minutes >= 1

    seconds = elapsed.total_seconds
    return "#{seconds.round(2)}s" if seconds >= 1

    millis = elapsed.total_milliseconds
    return "#{millis.round(2)}ms" if millis >= 1

    "#{(millis * 1000).round(2)}µs"
  end
end
