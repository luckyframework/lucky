class Webpack::Watch < LuckyCli::Task
  banner "Compile and watch assets with webpack"

  def call
    lucky_env = ENV["LUCKY_ENV"]? || "development"
    ENV["NODE_ENV"] = lucky_env

    Process.run "yarn",
      ["run", "webpack", "--", "--watch", "--config", "./config/webpack/#{lucky_env}.js"],
      output: true,
      error: true,
      shell: true
  end
end
