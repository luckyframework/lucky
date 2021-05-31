require "uuid/json"

abstract class Lucky::Serializer
  abstract def render

  def to_json(io)
    render.to_json(io)
  end
end
