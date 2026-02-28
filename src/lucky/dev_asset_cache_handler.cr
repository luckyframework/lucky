# Makes sure browser cache for assets is busted at every request in development.
class Lucky::DevAssetCacheHandler
  include HTTP::Handler

  ASSET_EXTENSIONS = %w[
    .js
    .css
    .map
    .json
    .png
    .jpg
    .jpeg
    .gif
    .svg
    .webp
    .woff
    .woff2
    .ttf
    .eot
  ]

  def call(context : HTTP::Server::Context) : Nil
    if LuckyEnv.development? && asset_request?(context.request.path)
      context.response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"
      context.response.headers["Pragma"] = "no-cache"
      context.response.headers["Expires"] = "0"
    end

    call_next(context)
  end

  private def asset_request?(path : String) : Bool
    ASSET_EXTENSIONS.any? { |ext| path.ends_with?(ext) }
  end
end
