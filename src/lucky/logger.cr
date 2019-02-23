require "logger"
require "./base_log_formatter"
require "./pretty_log_formatter"
require "./json_log_formatter"

class Lucky::Logger < Logger
  property log_formatter : Lucky::BaseLogFormatter

  # The built-in Crystal Logger requires a formatter, but we don't use it.
  # We instead override the `write` method and use our own formatter that
  # accepts a NamedTuple instead of a string
  private UNUSED_FORMATTER = Formatter.new do |_, _, _, _, _|
    # unused
  end

  def initialize(
    @io : IO?,
    @level = Severity::INFO,
    @log_formatter = Lucky::PrettyLogFormatter.new,
    @progname = ""
  )
    @formatter = UNUSED_FORMATTER
    @closed = false
    @mutex = Mutex.new
  end

  {% for name in ::Logger::Severity.constants %}
    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    def {{name.id.downcase}}(data : NamedTuple) : Void
      log(Severity::{{name.id}}, data)
    end

    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    #
    # Same as `{{ name.id }} but does not require surrounding data with {}:
    #
    # Example: `Lucky::Logger.new(STDOUT).{{ name.id }}(data: "my_data")`
    def {{name.id.downcase}}(**data) : Void
      log(Severity::{{name.id}}, data)
    end
  {% end %}

  def log(severity : ::Logger::Severity, **data) : Void
    log(severity: severity, data: data)
  end

  def log(severity : ::Logger::Severity, data : NamedTuple) : Void
    return if severity < level || !@io
    write(severity, Time.now, @progname, data)
  end

  # :nodoc:
  def formatter=(value) : Void
    {% raise "Use log_formatter= instead" %}
  end

  private def write(severity : ::Logger::Severity, datetime : Time, progname, message : String | NamedTuple) : Void
    io = @io
    return unless io

    data = if message.is_a?(String)
             {message: message}
           else
             message
           end

    progname_to_s = progname.to_s
    @mutex.synchronize do
      log_formatter.format(
        severity: severity,
        timestamp: datetime,
        progname: progname_to_s,
        data: data,
        io: io
      )
      io.puts
      io.flush
    end
  end
end
