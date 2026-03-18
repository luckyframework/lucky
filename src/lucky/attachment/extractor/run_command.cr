# Some extractors may need to call on command-line tools to extract certain
# data. This module will provide a helper to simplify running commands.
#
# ```
# struct ColourspaceFromIdentify
#   include Lucky::Attachment::Extractor
#   include Lucky::Attachment::Extractor::RunCommand
#
#   def extract(uploaded_file, metadata, **options) : String?
#     run_command(
#       "magick",
#       ["identify", "-format", "%[colorspace]"],
#       uploaded_file
#     )
#   end
# end
# ```
#
module Lucky::Attachment::Extractor::RunCommand
  # Runs the given command on the given IO object and returns the resulting
  # string if the command was successful.
  private def run_command(
    command : String,
    args : Array(String),
    input : IO,
  ) : String?
    stdout, stderr = IO::Memory.new, IO::Memory.new
    result = Process.run(
      command,
      args: args + ["-"],
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
    raise CliToolNotFound.new("The `#{command}` command-line tool is not installed")
  end

  # Convenience method accepting the `Lucky::UploadedFile` wrapper instead of
  # the `IO`.
  private def run_command(
    command : String,
    args : Array(String),
    uploaded_file : Lucky::UploadedFile,
  ) : String?
    run_command(command, args, uploaded_file.tempfile)
  end
end
