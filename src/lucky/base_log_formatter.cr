abstract class Lucky::BaseLogFormatter
  abstract def format(
    severity : ::Logger::Severity,
    timestamp : Time,
    progname : String,
    data : NamedTuple,
    io : IO
  ) : Nil
end
