class Lucky::RouteHandler
  include HTTP::Handler

  Habitat.create do
    setting mime_extensions : Hash(String, String) = {} of String => String
  end

  def call(context)
    original_path = context.request.path
    format = get_extension(context.request.path)
    context.request.path = context.request.path.gsub(format.to_s, "") if format
    handler = Lucky::Router.find_action(context.request)
    if handler
      if format && (content_type = MIME.from_extension?(format))
        Lucky.logger.debug({path_extension: format, new_content_type: content_type})
        context.request.headers["Content-Type"] = content_type
      end
      Lucky.logger.debug({handled_by: handler.payload.to_s})
      handler.payload.new(context, handler.params).perform_action
    else
      context.request.path = original_path
      call_next(context)
    end
  end

  # Returns a file extension from a path and excludes query string
  # `get_extension("/reports.xml.rss?page=1") #=> ".xml.rss"`
  private def get_extension(path : String)
    extension_idx = path.index('.')

    if extension_idx
      query_idx = (path.index('?') || 0)
      path[extension_idx..query_idx - 1]
    end
  end
end
