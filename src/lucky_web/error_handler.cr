class LuckyWeb::ErrorHandler
  include HTTP::Handler

  private getter action

  def initialize(@action : LuckyWeb::ErrorAction.class)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    action.new(context).perform_action(error)
    context
  end
end
