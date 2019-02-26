require "../spec_helper"

describe Lucky::PrettyLogFormatter do
  context "special cases" do
    it "pretty formats data for the start of an HTTP request" do
      io = IO::Memory.new
      format(io, {method: "GET", path: "/foo"})

      io.to_s.chomp.should start_with("GET #{"/foo".colorize.underline}")
    end

    it "pretty formats data for the end of an HTTP request" do
      io = IO::Memory.new
      format(io, {status: 200, duration: "1.4ms"})

      io.to_s.chomp.should start_with("Sent #{"200".colorize(:green)} (1.4ms)")
    end
  end

  context "when given data that is not the start/end of an HTTP request " do
    it "prints message text with an arrow" do
      io = IO::Memory.new
      format(io, {message: "some text"})

      io.to_s.chomp.should eq " #{"▸".colorize.dim} some text"
    end

    it "humanizes keys in key value pairs and prints with an arrow" do
      io = IO::Memory.new
      format(io, {failed_to_save: "SignUpForm"})

      io.to_s.chomp.should eq(" #{"▸".colorize.dim} Failed to save #{"SignUpForm".colorize.bold}")
    end

    it "formats multiple key value pairs" do
      io = IO::Memory.new
      format(io, {first_thing: "one", second_thing: "two"})

      io.to_s.chomp.should eq(" #{"▸".colorize.dim} First thing #{"one".colorize.bold}. Second thing #{"two".colorize.bold}")
    end
  end

  it "uses a red arrow for ERRORS and above" do
    io = IO::Memory.new
    format(io, severity: Logger::Severity::ERROR, data: {message: "message"})

    io.to_s.chomp.should eq(" #{"▸".colorize.red} message")
  end

  it "uses a yellow arrow for warnings and colors the first value" do
    io = IO::Memory.new
    format(io, severity: Logger::Severity::WARN, data: {first: "message", second: "message"})

    io.to_s.chomp.should eq(" #{"▸".colorize.yellow} First #{"message".colorize.yellow.bold}. Second #{"message".colorize.bold}")
  end
end

private def format(io, data : NamedTuple, severity = Logger::Severity::INFO)
  Lucky::PrettyLogFormatter.new(
    severity: severity,
    timestamp: Time.now,
    progname: "",
    io: io
  ).format(data)
end
