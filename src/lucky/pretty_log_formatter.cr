struct Lucky::PrettyLogFormatter < Dexter::BaseFormatter
  ENTRY_FORMATTERS = [
    RequestStartedFormatter,
    RequestEndedFormatter,
    ExceptionFormatter,
    AnyOtherDataFormatter,
  ]

  def call : Nil
    ENTRY_FORMATTERS.each do |entry_formatter|
      formatter = entry_formatter.new(io, entry)

      if formatter.should_format?
        formatter.write
        break
      end
    end
  end

  private abstract class EntryFormatter
    private getter io, entry
    delegate severity, to: entry

    def initialize(@io : IO, @entry : ::Log::Entry)
    end

    abstract def should_format? : Bool

    abstract def write : Nil

    def local_context
      res = Hash(String, ::Log::Metadata::Value).new

      entry.context[:local]?.try &.as_h.each do |key, value|
        res[key.to_s] = value
      end

      res
    end

    private def add_arrow : Nil
      io << " #{arrow} "
    end

    private def arrow
      arrow = "▸"

      case severity.value
      when ::Log::Severity::Warn.value
        arrow.colorize.yellow
      when .>= ::Log::Severity::Error.value
        arrow.colorize.red
      else
        arrow.colorize.dim
      end
    end

    private def add_request_id : Nil
      if id = local_context["request_id"].to_s.presence
        io << " (#{id.colorize.dim})"
      end
    end
  end

  private class RequestStartedFormatter < EntryFormatter
    def should_format? : Bool
      (Lucky::LogHandler::REQUEST_START_KEYS.values.to_a - local_context.keys).empty?
    end

    def write : Nil
      io << "\n#{local_context["method"]} #{local_context["path"].colorize.underline}"
      add_request_id
    end
  end

  private class RequestEndedFormatter < EntryFormatter
    def should_format? : Bool
      (Lucky::LogHandler::REQUEST_END_KEYS.values.to_a - local_context.keys).empty?
    end

    def write : Nil
      add_arrow
      http_status = Lucky::LoggerHelpers.colored_http_status(local_context["status"].as_i)
      io << "Sent #{http_status} (#{local_context["duration"]})"
      add_request_id
    end
  end

  private class ExceptionFormatter < EntryFormatter
    def should_format? : Bool
      entry.exception.present?
    end

    def write : Nil
      add_arrow
      entry.exception.try do |ex|
        io << " #{ex.class.name} ".colorize.bold.on_red
        if ex.message.try(&.lines)
          io << "\n"
          ex.message.try(&.lines).try(&.each do |line|
            io << "\n     "
            io << line
          end)
        end
        if backtrace = ex.backtrace?
          io << "\n\n   "
          io << " Backtrace ".colorize.bold.black.on_white
          io << "\n"
          backtrace.each do |trace_line|
            trace_line = trace_line.colorize.dim unless trace_line.starts_with?(/src|spec/)
            io << "\n     #{trace_line}"
          end
          io << "\n"
        end
      end
    end
  end

  private class AnyOtherDataFormatter < EntryFormatter
    private property index = 0

    def should_format? : Bool
      true
    end

    def write : Nil
      add_arrow
      io << "#{entry.message}" unless entry.message.empty?

      io << local_context.map do |key, value|
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
      severity.value == ::Log::Severity::Warn.value && index.zero?
    end
  end
end
