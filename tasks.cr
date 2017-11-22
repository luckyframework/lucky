require "lucky_cli"
require "./src/lucky"
require "./src/app/**"
require "./tasks/**"

LuckyCli::Runner.run
