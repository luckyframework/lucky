require "colorize"

class Lucky::RouteHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    original_path = context.request.path

    # Extract format from URL path and strip it for route matching
    if url_format = Lucky::MimeType.extract_format_from_path(original_path)
      context._url_format = url_format
      # Create a modified request with format-stripped path for route matching
      path_without_format = original_path.sub(/\.[a-zA-Z0-9]+(?:\?.*)?$/, "")
      modified_request = context.request.dup
      modified_request.path = path_without_format
      lookup_request = modified_request
    else
      lookup_request = context.request
    end

    handler = Lucky.router.find_action(lookup_request)
    if handler
      Lucky::Log.dexter.debug { {handled_by: handler.payload.to_s} }
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end
end
