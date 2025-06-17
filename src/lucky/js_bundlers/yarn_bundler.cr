class Lucky::JSBundlers::YarnBundler < Lucky::JSBundlers::BaseJSBundler
  def self.install_command
    "yarn install"
  end

  def self.run_command
    "yarn run"
  end
end
