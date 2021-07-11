require "http/server"

class Lucky::StaticFileHandler < HTTP::StaticFileHandler
  def call(context : HTTP::Server::Context)
    super(context)
  end
end
