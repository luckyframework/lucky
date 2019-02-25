require "../spec_helper"

private class RawFormatter < Lucky::BaseLogFormatter
  def format(
    severity,
    timestamp,
    progname,
    data,
    io
  )
    io << data
  end
end

describe Lucky::Logger do
  it "inherits from the Crytal Logger" do
    build_logger.should be_a(::Logger)
  end

  it "converts string into NamedTuple" do
    io = IO::Memory.new
    logger = build_logger(io)

    logger.info("Something")

    io.to_s.chomp.should eq(%({message: "Something"}))
  end

  it "converts string into NamedTuple" do
    io = IO::Memory.new
    logger = build_logger(io)

    logger.info("Something")

    io.to_s.chomp.should eq(%({message: "Something"}))
  end

  it "allows logging key/value data" do
    io = IO::Memory.new
    logger = build_logger(io)

    logger.log(Logger::Severity::INFO, foo: "bar")

    io.to_s.chomp.should eq(%({foo: "bar"}))
  end

  {% for name in ::Logger::Severity.constants %}
    it "logs key/value data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      logger = build_logger(io)

      logger.{{ name.id.downcase }}({foo: "bar"})

      io.to_s.chomp.should eq(%({foo: "bar"}))
    end

    it "logs splatted key/value data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      logger = build_logger(io)

      # Surrounding {} not required:
      logger.{{ name.id.downcase }}(foo: "bar")

      io.to_s.chomp.should eq(%({foo: "bar"}))
    end
  {% end %}
end

private def build_logger(io = STDOUT)
  Lucky::Logger.new(io, level: Logger::Severity::DEBUG).tap do |logger|
    logger.log_formatter = RawFormatter.new
  end
end
