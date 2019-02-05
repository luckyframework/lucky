require "http/server"

class Lucky::StaticFileHandler < HTTP::StaticFileHandler
  Habitat.create do
    setting hide_from_logs : Bool
  end

  def call(context : HTTP::Server::Context)
    context.hide_from_logs = settings.hide_from_logs
    super(context)
  end
end
