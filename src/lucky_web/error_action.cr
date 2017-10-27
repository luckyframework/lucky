require "./*"

abstract class LuckyWeb::ErrorAction
  include LuckyWeb::ActionDelegates
  include LuckyWeb::Renderable
  include LuckyWeb::Redirectable

  getter context

  def initialize(@context : HTTP::Server::Context)
  end

  abstract def handle_error(error : Exception) : LuckyWeb::Response

  def perform_action(error : Exception)
    handle_error(error).print
  end
end
