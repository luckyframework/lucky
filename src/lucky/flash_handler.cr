class Lucky::FlashHandler
  include HTTP::Handler

  def call(context)
    call_next(context)
  ensure
    context.session.set(Lucky::FlashStore::SESSION_KEY, context.flash.to_json)
  end
end
