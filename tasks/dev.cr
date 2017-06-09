class Dev < LuckyCli::Task
  banner "Start a Lucky server using heroku local and Procfile.dev"

  def call
    Process.run "heroku", ["local", "--procfile", "Procfile.dev"],
      error: true,
      output: true,
      shell: true
  end
end
