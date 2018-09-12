class Lucky::FlashHandler
  include HTTP::Handler

  def call(context)
    call_next(context)
  ensure
    context.better_session.set(Lucky::FlashStore::SESSION_KEY, context.flash.to_json)
  end
end
