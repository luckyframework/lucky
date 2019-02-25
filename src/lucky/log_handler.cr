require "colorize"

class Lucky::LogHandler
  include HTTP::Handler

  delegate logger, to: settings

  Habitat.create do
    setting logger : Lucky::Logger
  end

  def call(context)
    time = Time.now
    log_request_start(context) unless context.hide_from_logs?
    call_next(context)
    log_request_end(context, duration: Time.now - time) unless context.hide_from_logs?
  rescue e
    log_exception(context, time, e)
    raise e
  end

  private def log_request_start(context)
    logger.info({
      method: context.request.method,
      path:   context.request.resource,
    })
  end

  private def log_request_end(context, duration)
    logger.info({
      status:   context.response.status_code,
      duration: Lucky::LoggerHelpers.elapsed_text(duration),
    })
  end

  private def log_exception(context, time, e)
    logger.error({unhandled_exception: e.inspect_with_backtrace})
  end
end
