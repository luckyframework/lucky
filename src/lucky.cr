require "wordsmith"
require "exception_page"
require "habitat"
require "cry"
require "dexter"
require "pulsar"
require "./lucky/memoizable"
require "./lucky/quick_def"
require "./charms/*"
require "http/server"
require "lucky_router"
require "./lucky/events/*"
require "./lucky/support/*"
require "./lucky/renderable_error"
require "./lucky/errors"
require "./lucky/response"
require "./lucky/cookies/*"
require "./lucky/secure_headers/*"
require "./lucky/route_helper"
require "./lucky/*"
require "./lucky/paginator/paginator"
require "./lucky/paginator/*"
require "./lucky/paginator/components/*"

module Lucky
  ROUTER = Lucky::Router.new

  Log              = ::Log.for("lucky")
  ContinuedPipeLog = Log.for("continued_pipe_log")

  # Use Dir.current to return the root folder of your Lucky application.
  #
  # In some frameworks there is a method called `root` that returns the root directory of the project.
  # In Crystal there is a built-in method for this: `Dir.current`. This method exists purely to help new users
  # find `Dir.current`. If you call `Lucky.root` it will raise a compile-time error directing you to use `Dir.current`
  def self.root
    {% raise "Please use Crystal's 'Dir.current' to return the root folder of your Lucky application." %}
  end

  def self.router : Lucky::Router
    ROUTER
  end
end
