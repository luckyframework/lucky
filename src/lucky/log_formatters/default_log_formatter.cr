class DefaultLogFormatter < Lucky::LogFormatters::Base
  def format(context, time, elapsed) : String
    "#{context.request.method} #{colored_status_code(context.response.status_code)} #{context.request.resource}#{timestamp(time)} (#{elapsed_text(elapsed)})"
  end
end
