require "../spec_helper"

include ShouldRunSuccessfully

Spec.before_each { FileUtils.rm_rf("tmp") }

describe "Encrypting config with Enigma" do
  it "encrypts and decrypts" do
    should_run_successfully "shards build"
    folder = "tmp/enigma"
    FileUtils.mkdir_p folder

    Dir.cd folder do
      should_run_successfully "git init enigma-test"
      Dir.cd "enigma-test"
      FileUtils.cp_r("../../../bin", "bin")
      FileUtils.mkdir_p "config/encrypted"
      File.write ".gitignore", "/log/"
      File.write "leave-me-alone", "stays raw"
      File.write "config/encrypted/encrypt-me", "gets encrypted"
      setup_enigma(key: "123abc")

      should_run_successfully "git add -A", output: IO::Memory.new
      should_run_successfully "git commit -m 'Initial commit'", output: IO::Memory.new

      should_have_set_key("123abc")
      should_be_setup_to_encrypt("config/encrypted/*")
      should_encrypt_file(
        "config/encrypted/encrypt-me",
        decrypted_contents: "gets encrypted",
        encrypted_in_git: "U2FsdGVkX19vbGeSXJy1Ce4D7Wpu3rt1891279E0/Ug=\n")
      should_not_encrypt("leave-me-alone", contents: "stays raw")

      should_run_successfully "git checkout -b switch-branches"
      File.write "config/encrypted/encrypt-me", "gets encrypted and more"
      should_run_successfully "git add -A"
      should_run_successfully "git commit -m 'Test it out'"
      should_encrypt_file(
        "config/encrypted/encrypt-me",
        decrypted_contents: "gets encrypted and more",
        encrypted_in_git: "U2FsdGVkX1+NehDpj3cKcdrEGtN1j568TaDHVLy4PLzBEr0iO4RT+PVrYbSd2Ajj\n")

      should_run_successfully "git checkout master"
      should_encrypt_file(
        "config/encrypted/encrypt-me",
        decrypted_contents: "gets encrypted\n",
        encrypted_in_git: "U2FsdGVkX19vbGeSXJy1Ce4D7Wpu3rt1891279E0/Ug=\n")
      should_not_encrypt("leave-me-alone", contents: "stays raw")

      # Uninstall process
      should_run_successfully "./bin/enigma.uninstall"
      File.read(".gitattributes").should eq ""
      File.read("config/encrypted/encrypt-me").should eq("U2FsdGVkX19vbGeSXJy1Ce4D7Wpu3rt1891279E0/Ug=\n")
      # Should show decrypted version as uncommitted
      `git status`.should contain(".gitattributes")
      `git status`.should contain("config/encrypted/encrypt-me")
    end
  end
end

private def setup_enigma(key)
  Enigma::Setup.new.call(key, IO::Memory.new)
end

private def should_have_set_key(key)
  should_run_successfully("git config lucky.enigma.key") { |output| output.should eq(key) }
end

private def should_be_setup_to_encrypt(folder)
  File.read(".gitattributes").should contain "#{folder} filter=enigma diff=enigma"
end

private def should_encrypt_file(path, decrypted_contents, encrypted_in_git)
  File.read("config/encrypted/encrypt-me").should eq decrypted_contents
  `git --no-pager show HEAD:"#{path}"`.should eq encrypted_in_git
end

private def should_not_encrypt(path, contents)
  File.read("leave-me-alone").should eq contents
end
