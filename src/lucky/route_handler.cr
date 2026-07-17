require "colorize"

class Lucky::RouteHandler
  include HTTP::Handler

  # Assuming a request path comes in for `/reports.json`,
  # we find and actions with an explicit extension set like `/reports.json`. If none are found,
  # then we look for `/reports` that accepts the json mime type.
  def call(context : HTTP::Server::Context)
    original_path = context.request.path
    method = context.request.method
    handler = Lucky.router.find_action(method, original_path)

    if url_format = Lucky::MimeType.extract_format_from_path(original_path)
      if handler.nil? || format_absorbed_by_param?(handler, original_path)
        context._url_format = url_format
        path_without_format = original_path.sub(/^([^?]*)\.[a-zA-Z0-9]+(\?.*)?$/, "\\1\\2")
        handler = Lucky.router.find_action(method, path_without_format)
      end
    end

    if handler
      Lucky::Log.dexter.debug { {handled_by: handler.payload.to_s} }
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end

  private def format_absorbed_by_param?(match : LuckyRouter::Match(Lucky::Action.class), path : String) : Bool
    if extension_match = path.match(/^[^?]*\.([a-zA-Z0-9]+)(?:\?|$)/)
      extension = extension_match[1]
      match.params.values.any?(&.ends_with?(".#{extension}"))
    else
      false
    end
  end
end
