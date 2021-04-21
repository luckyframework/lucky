require "./html_builder"

module Lucky::HTMLPage
  Habitat.create do
    setting render_component_comments : Bool = false
  end

  include Lucky::HTMLBuilder
  getter view = IO::Memory.new

  def to_s(io)
    io << view
  end
end
