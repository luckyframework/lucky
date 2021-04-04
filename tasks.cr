require "lucky_task"
require "./src/lucky"
require "./src/app/**"
require "./tasks/**"

LuckyTask::Runner.run
