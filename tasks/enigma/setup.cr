class Enigma::Setup < LuckyCli::Task
  banner "Setup encrypted configuration with Engima"

  # TODO: Generate a super secret key
  def call(key : String = "")
    run "git config lucky.enigma.key #{key}"
  end

  private def run(command)
    Process.run(command, shell: true, output: STDOUT, error: STDERR)
  end
end
