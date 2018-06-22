require "http/server"

class Lucky::StaticFileHandler < HTTP::StaticFileHandler
  Habitat.create do
    setting hide_from_logs : Bool
  end

  def call(context : HTTP::Server::Context)
    context.hide_from_logs = settings.hide_from_logs
    super(context)
  end

  private def mime_type(path)
    case File.extname(path)
    when ".txt"          then "text/plain"
    when ".htm", ".html" then "text/html"
    when ".css"          then "text/css"
    when ".js"           then "application/javascript"
    when ".svg"          then "image/svg+xml"
    when ".svgz"         then "image/svg+xml"
    when ".eot"          then "application/vnd.ms-fontobject"
    when ".ttf"          then "font/ttf"
    when ".woff"         then "font/woff"
    when ".woff2"        then "font/woff2"
    else                      "application/octet-stream"
    end
  end
end
