# https://git-scm.com/docs/gitattributes
class Enigma::Setup < LuckyCli::Task
  GIT_CONFIG_PATH_TO_KEY = "lucky.enigma.key"
  GIT_CONFIG             = {
    "filter.enigma.clean"    => "./bin/clean %f",
    "filter.enigma.smudge"   => "./bin/smudge",
    "filter.enigma.required" => "true",
    "diff.enigma.textconv"   => "./bin/textconv",
    "diff.enigma.binary"     => "true",

    # To prevent these unnecessary merge conflicts, Git can be told to run a
    # virtual check-out and check-in of all three stages of a file when
    # resolving a three-way merge by setting the merge.renormalize
    # configuration variable. This prevents changes caused by check-in
    # conversion from causing spurious merge conflicts when a converted file is
    # merged with an unconverted file.
    "merge.renormalize" => "true",
  }

  banner "Setup encrypted configuration with Engima"

  def call(key : String = generate_key, io : IO = STDOUT)
    if not_installed_yet?
      setup_key(key, io)
      tell_git_to_use_enigma_for_encryption
      tell_git_to_encrypt("config/encrypted/*")

      puts "Enigma is set up with key: #{key}"
    else
      puts "Enigma is already set up. Did nothing."
    end
  end

  private def setup_key(key, io)
    run "git config --local #{GIT_CONFIG_PATH_TO_KEY} #{key}", io
  end

  private def tell_git_to_encrypt(path : String)
    # TODO Only add top line
    # config/encrypted/* filter=crypt diff=crypt
    ::File.write ".gitattributes", <<-TEXT
    #{path} filter=enigma diff=enigma

    TEXT
  end

  private def tell_git_to_use_enigma_for_encryption
    GIT_CONFIG.each do |key, value|
      run %(git config #{key} '#{value}')
    end
  end

  private def run(command, io = STDOUT)
    Process.run(command, shell: true, output: io, error: STDERR)
  end

  private def not_installed_yet? : Bool
    key_from_git = `git config #{GIT_CONFIG_PATH_TO_KEY}`
    key_from_git.blank?
  end

  @_key : String?

  private def key : String
    @_key ||= `git config #{Enigma::Setup::GIT_CONFIG_PATH_TO_KEY}`
  end

  private def generate_key : String
    Random::Secure.base64(32)
  end
end
