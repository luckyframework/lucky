require "colorize"

class Lucky::LogHandler
  include HTTP::Handler

  Habitat.create do
    setting skip_if : Proc(HTTP::Server::Context, Bool)?
  end

  delegate logger, to: Lucky

  def call(context)
    time = Time.utc
    should_skip = settings.skip_if.try &.call(context)

    log_request_start(context) unless should_skip
    call_next(context)
    log_request_end(context, duration: Time.utc - time) unless should_skip
  rescue e
    log_exception(context, time, e)
    raise e
  end

  private def log_request_start(context) : Nil
    logger.info({
      method: context.request.method,
      path:   context.request.resource,
    })
  end

  private def log_request_end(context, duration) : Nil
    logger.info({
      status:   context.response.status_code,
      duration: Lucky::LoggerHelpers.elapsed_text(duration),
    })
  end

  private def log_exception(context, time, e) : Nil
    logger.error({unhandled_exception: e.inspect_with_backtrace})
  end
end
