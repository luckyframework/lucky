# The Base class for creating an app server in Lucky
abstract class Lucky::BaseAppServer
  private getter server

  abstract def middleware : Array(HTTP::Handler)
  abstract def listen

  def initialize
    @server = HTTP::Server.new(middleware)
    resize_execution_context(Lucky::Server.settings.workers)
  end

  private def resize_execution_context(workers : Int32) : Nil
    return if workers == 1

    {% if Fiber.has_constant?(:ExecutionContext) && Fiber::ExecutionContext.has_constant?(:Parallel) %}
      Fiber::ExecutionContext.default.resize(workers)
    {% else %}
      Lucky::Log.dexter.warn { {crystal_version: "does not support execution contexts."} }
    {% end %}
  end

  # :nodoc:
  def host : String
    Lucky::Server.settings.host
  end

  # :nodoc:
  def port : Int32
    Lucky::Server.settings.port
  end

  # :nodoc:
  def close : Nil
    server.close
  end
end
