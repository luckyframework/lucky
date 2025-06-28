abstract class Lucky::HTTP2::Action
  getter context : HT2::Context
  getter route_params : Hash(String, String)

  def initialize(@context : HT2::Context, @route_params : Hash(String, String))
  end

  def self.call(context : HT2::Context, route_params : Hash(String, String))
    action = new(context, route_params)
    action.call
  end

  abstract def call
end
