require "../spec_helper"

include ShouldRunSuccessfully

describe "Encrypting config with Enigma" do
  it "encrypts and decrypts" do
    folder = "tmp/enigma"
    FileUtils.mkdir_p folder

    Dir.cd folder do
      should_run_successfully "git init enigma-test"
      Dir.cd "enigma-test"

      FileUtils.mkdir_p "config/encrypted"
      File.write "leave-me-alone", "stays raw"
      File.write "config/encrypted/encrypt-me", "gets encrypted"
      should_run_successfully "git add -A"
      should_run_successfully "git commit -m 'Initial commit'"

      setup_enigma

      should_have_set_key
      should_be_setup_to_encrypt("config/encrypted")
      should_encrypt_file("config/encrypted/encrypt-me")
      should_not_encrypt("leave-me-alone")
    end
  end
end

private def should_have_set_key
  should_run_successfully("git config lucky.enigma.key") # Should check for a specific value
end

private def should_be_setup_to_encrypt(folder)
end

private def should_encrypt_file(path)
end

private def should_not_encrypt(path)
end
