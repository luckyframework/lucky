require "./html_builder"

module Lucky::HTMLPage
  include Lucky::HTMLBuilder

  Habitat.create do
    setting render_component_comments : Bool = false
  end

  getter view : IO = IO::Memory.new
  needs context : HTTP::Server::Context

  def to_s(io)
    io << view
  end
end
