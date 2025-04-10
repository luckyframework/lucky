require "uuid/json"

module Lucky::Serializable
  abstract def render

  def to_json(io)
    render.to_json(io)
  end
end
