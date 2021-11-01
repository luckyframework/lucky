require "colorize"

class Lucky::LogHandler
  include HTTP::Handler
  # These constants are used here and in the PrettyLogFormatter to make sure
  # that the formatter looks for the right keys!
  REQUEST_START_KEYS = {
    method: "method",
    path:   "path",
  }

  REQUEST_END_KEYS = {
    status:   "status",
    duration: "duration",
  }

  Habitat.create do
    setting skip_if : Proc(HTTP::Server::Context, Bool)?
  end

  delegate logger, to: Lucky

  def call(context)
    should_skip_logging = settings.skip_if.try &.call(context)

    if should_skip_logging
      call_next(context)
    else
      log_request_start(context)

      duration = Time.measure do
        call_next(context)
      end

      log_request_end(context, duration: duration)
      Lucky::Events::RequestCompleteEvent.publish(duration)
    end
  rescue e
    log_exception(context, Time.utc, e)
    raise e
  end

  private def log_request_start(context : HTTP::Server::Context) : Nil
    Lucky::Log.dexter.info do
      {
        REQUEST_START_KEYS[:method] => context.request.method,
        REQUEST_START_KEYS[:path]   => context.request.resource,
      }
    end
  end

  private def log_request_end(context : HTTP::Server::Context, duration : Time::Span) : Nil
    Lucky::Log.dexter.info do
      {
        REQUEST_END_KEYS[:status]   => context.response.status_code,
        REQUEST_END_KEYS[:duration] => Lucky::LoggerHelpers.elapsed_text(duration),
      }
    end
  end

  private def log_exception(context : HTTP::Server::Context, time : Time, e : Exception) : Nil
    Lucky::Log.error(exception: e) { "" }
  end
end
