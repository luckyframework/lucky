require "lucky_cli"

class Gen::SecretKey < LuckyCli::Task
  banner "Generate a new secret key"

  def call(io : IO = STDOUT)
    io.puts Random::Secure.base64(32)
  end
end
