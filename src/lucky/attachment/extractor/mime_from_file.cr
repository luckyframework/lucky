struct Lucky::Attachment::Extractor::MimeFromFile
  include Lucky::Attachment::Extractor

  # Extracts the MIME type using the `file` utility, and raises when it's not
  # installed.
  def extract(io, metadata, **options) : String?
    # Avoids returning "application/x-empty" for empty files
    return nil if io.size.try &.zero?

    stdout, stderr = IO::Memory.new, IO::Memory.new
    command = Process.run(
      "file",
      args: ["--mime-type", "--brief", "-"],
      output: stdout,
      error: stderr,
      input: io
    )

    if command.success?
      io.rewind
      stdout.to_s.strip
    else
      Log.debug { "Unable to extract MIME type using `file` utility (#{stderr})" }
    end
  rescue File::NotFoundError
    raise Error.new("file command-line tool is not installed")
  end
end
