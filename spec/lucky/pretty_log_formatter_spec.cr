require "../spec_helper"

include ContextHelper

describe Lucky::PrettyLogFormatter do
  context "special cases" do
    it "pretty formats data for the start of an HTTP request" do
      io = IO::Memory.new
      format(io, {method: "GET", path: "/foo", request_id: nil})

      io.to_s.chomp.should start_with("\nGET #{"/foo".colorize.underline}")
    end

    it "pretty formats data for the end of an HTTP request" do
      io = IO::Memory.new
      format(io, {status: 200, duration: "1.4ms", request_id: nil})

      io.to_s.chomp.should start_with(" #{"▸".colorize.dim} Sent #{"200 OK".colorize.bold} (1.4ms)")
    end

    it "includes the request_id in the start of an HTTP request" do
      io = IO::Memory.new
      format(io, {method: "GET", path: "/foo", request_id: "abc123"})

      io.to_s.chomp.should start_with("\nGET #{"/foo".colorize.underline} (#{"abc123".colorize.dim})")
    end

    it "includes the request_id in the end of an HTTP request" do
      io = IO::Memory.new
      format(io, {status: 200, duration: "1.4ms", request_id: "abc123"})

      io.to_s.chomp.should start_with(" #{"▸".colorize.dim} Sent #{"200 OK".colorize.bold} (1.4ms) (#{"abc123".colorize.dim})")
    end

    context "when request_id is empty" do
      it "does not include empty () in the end of an HTTP request" do
        io = IO::Memory.new
        format(io, {status: 200, duration: "1.4ms", request_id: ""})

        io.to_s.chomp.should eq(" #{"▸".colorize.dim} Sent #{"200 OK".colorize.bold} (1.4ms)")
      end
    end
  end

  context "when given data that is not the start/end of an HTTP request " do
    it "prints message text with an arrow" do
      io = IO::Memory.new

      format(io, data: nil, message: "some text")

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

    format(io, severity: Log::Severity::Error, data: {message: "anything"})

    io.to_s.chomp.should start_with(" #{"▸".colorize.red} Message")
  end

  it "uses a yellow arrow for warnings and colors the first value" do
    io = IO::Memory.new
    format(io, severity: Log::Severity::Warn, data: {first: "message", second: "message"})

    io.to_s.chomp.should eq(" #{"▸".colorize.yellow} First #{"message".colorize.yellow.bold}. Second #{"message".colorize.bold}")
  end

  it "formats exceptions" do
    io = IO::Memory.new
    ex = RuntimeError.new("Oops that wasn't supposed to happen")

    format(io, severity: Log::Severity::Error, data: nil, exception: ex)

    io.to_s.should start_with(" #{"▸".colorize.red}")
    io.to_s.should contain(" #{ex.class.name} ".colorize.bold.on_red.to_s)
  end
end

private def format(io, data : NamedTuple?, message : String = "", severity = Log::Severity::Info, exception : Exception? = nil)
  Log.with_context do
    Log.context.set(local: data) if data

    entry = Log::Entry.new \
      source: "lucky-test",
      message: message,
      severity: severity,
      data: Log::Metadata.build(Log::Metadata.empty),
      exception: exception

    Lucky::PrettyLogFormatter.new(
      entry: entry,
      io: io
    ).call
  end
end
