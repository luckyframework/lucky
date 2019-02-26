struct Lucky::PrettyLogFormatter < Dexter::Formatters::BaseLogFormatter
  private abstract class MessageFormatter
    class Continue; end

    private getter io, severity

    def initialize(@io : IO, @severity : ::Logger::Severity)
    end

    def format(_catch_all)
      Continue.new
    end

    private def add_arrow : Void
      io << " #{arrow} "
    end

    private def arrow
      arrow = "▸"

      case severity.value
      when Logger::Severity::WARN.value
        arrow.colorize.yellow
      when .>= Logger::Severity::ERROR.value
        arrow.colorize.red
      else
        arrow.colorize.dim
      end
    end
  end

  private class RequestStartedFormatter < MessageFormatter
    def format(data : NamedTuple(method: String, path: String))
      io << "#{data[:method]} #{data[:path].colorize.underline}"
    end
  end

  private class RequestEndedFormatter < MessageFormatter
    def format(data : NamedTuple(status: Int32, duration: String))
      colored_status_code = Lucky::LoggerHelpers.colored_status_code(data[:status])
      io << "Sent #{colored_status_code} (#{data[:duration]})"
    end
  end

  private class PlainTextFormatter < MessageFormatter
    def format(data : NamedTuple(message: String))
      add_arrow

      io << data[:message]
    end
  end

  private class AnyOtherDataFormatter < MessageFormatter
    private property index = 0

    def format(data : NamedTuple)
      add_arrow

      io << data.map do |key, value|
        "#{Wordsmith::Inflector.humanize(key)} #{colored(value.to_s)}".tap do
          self.index += 1
        end
      end.join(". ")
    end

    private def colored(value : String)
      if printing_first_value_of_warning?
        value.colorize.bold.yellow
      else
        value.colorize.bold
      end
    end

    private def printing_first_value_of_warning?
      severity.value == Logger::Severity::WARN.value && index.zero?
    end
  end

  MESSAGE_FORMATTERS = [
    RequestStartedFormatter,
    RequestEndedFormatter,
    PlainTextFormatter,
    AnyOtherDataFormatter,
  ]

  def format(data : NamedTuple) : Void
    MESSAGE_FORMATTERS.each do |message_formatter|
      result = message_formatter.new(io, severity).format(data)
      break unless result.is_a?(MessageFormatter::Continue)
    end
  end
end
