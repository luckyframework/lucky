require "uuid/json"
require "./serializable/format_macro"

module Lucky::Serializable
  abstract def render

  def to_json(io)
    render.to_json(io)
  end
end
