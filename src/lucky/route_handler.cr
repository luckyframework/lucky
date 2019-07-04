class Lucky::RouteHandler
  include HTTP::Handler

  Habitat.create do
    # A list of custom mime type extensions (e.g. {".lucky" => "application/lucky"}
    setting mime_extensions : Hash(String, String) = {} of String => String

    # Set to `false` to skip mime handling. Reverts to old lookup method
    setting handle_extensions : Bool = true
  end

  def call(context)
    if RouteHandler.settings.handle_extensions
      call_with_mime_lookup(context)
    else
      call_without_mime_lookup(context)
    end
  end

  private def call_with_mime_lookup(context)
    original_path = context.request.path
    extension = get_extension(context.request.path)
    context.request.path = context.request.path.gsub(extension[:format], "") if extension
    handler = Lucky::Router.find_action(context.request)
    if handler
      if extension
        Lucky.logger.warn({path_extension: extension[:format], changed_content_type_to: extension[:type]})
        context.request.headers["Content-Type"] = extension[:type]
      end
      Lucky.logger.debug({handled_by: handler.payload.to_s})
      handler.payload.new(context, handler.params).perform_action
    else
      context.request.path = original_path
      call_next(context)
    end
  end

  private def call_without_mime_lookup(context)
    handler = Lucky::Router.find_action(context.request)
    if handler
      Lucky.logger.debug({handled_by: handler.payload.to_s})
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end

  # Returns a `NamedTuple` with the file extension, and content type
  # from the `path` excluding any query string. Returns `nil` if no extension is registered.
  #
  # `get_extension("/reports.xml.rss?page=1")
  # => {format: ".xml.rss", type: "application/rss"}
  private def get_extension(path : String) : NamedTuple(format: String, type: String)?
    extension_idx = path.index('.')

    if extension_idx
      query_idx = (path.index('?') || 0)
      extension = path[extension_idx..query_idx - 1]
      if content_type = MIME.from_extension?(extension)
        return {format: extension.to_s, type: content_type}
      end
    end

    nil
  end
end
