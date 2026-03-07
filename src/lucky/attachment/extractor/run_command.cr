module Lucky::Attachment::Extractor::RunCommand
  # Helper method to execute command-line tools for metadata extractors.
  private def run_command(
    command : String,
    args : Array(String),
    input : IO,
  ) : String?
    stdout, stderr = IO::Memory.new, IO::Memory.new
    result = Process.run(
      command,
      args: args.push("-"),
      output: stdout,
      error: stderr,
      input: input
    )
    input.rewind

    return stdout.to_s.strip if result.success?

    Log.debug do
      "Unable to extract data with `#{command} #{args.join(' ')}` (#{stderr})"
    end
  rescue File::NotFoundError
    raise Error.new("The `#{command}` command-line tool is not installed")
  end
end
