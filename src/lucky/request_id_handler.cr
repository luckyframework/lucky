# Sets the HTTP::Server::Context#request_id value
#
# Configure the `set_request_id` Proc to return a
# new `String` value on each request. This can be
# used to group logs and such that may be ran asynchronously.
#
# ```
# Lucky::RequestIdHandler.configure do |settings|
#   settings.set_request_id = ->(context : HTTP::Server::Context) {
#     UUID.random.to_s
#   }
# end
# ```
class Lucky::RequestIdHandler
  include HTTP::Handler

  Habitat.create do
    setting set_request_id : Proc(HTTP::Server::Context, String)? = nil
  end

  def call(context)
    context.request_id = settings.set_request_id.try &.call(context)

    call_next(context)
  end
end
