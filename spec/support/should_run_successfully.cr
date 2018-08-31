module ShouldRunSuccessfully
  private def should_run_successfully(command, output io : IO? = nil) : Void
    result = Process.run(
      command,
      shell: true,
      output: io || STDOUT,
      error: STDERR
    )

    result.exit_status.should be_successful
  end

  private def should_run_successfully(command) : Void
    io = IO::Memory.new

    result = Process.run(
      command,
      shell: true,
      output: io,
      error: STDERR
    )

    result.exit_status.should be_successful
    yield io.to_s.chomp
  end

  private def be_successful
    eq 0
  end
end
