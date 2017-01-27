require "lucky_cli"
require "./src/lucky_web"
require "./src/app/*"
require "./tasks/*"

LuckyCli::Runner.run
