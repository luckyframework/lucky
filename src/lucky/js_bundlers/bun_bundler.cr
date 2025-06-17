class Lucky::JSBundlers::BunBundler < Lucky::JSBundlers::BaseJSBundler
  def self.install_command
    "bun install"
  end

  def self.run_command
    "bun run"
  end
end
