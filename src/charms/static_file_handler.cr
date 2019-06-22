require "http/server"

class Lucky::StaticFileHandler < HTTP::StaticFileHandler
  def call(context : HTTP::Server::Context)
    super(context)
  end

  def self.configure(*args, **named_args, &block)
    {% raise "All settings were removed from Lucky::StaticFileHandler. You can remove the Lucky::StaticFileHandler.configure block." %}
  end
end
