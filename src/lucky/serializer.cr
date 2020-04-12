require "uuid/json"

abstract class Lucky::Serializer
  def to_json(io)
    render.to_json(io)
  end
end
