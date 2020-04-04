require "./html_builder"

module Lucky::HTMLPage
  Habitat.create do
    setting render_component_comments : Bool = false
  end

  macro included
    include Lucky::HTMLBuilder
    getter view = IO::Memory.new
    needs context : HTTP::Server::Context
  end

  def to_s(io)
    io << view
  end
end
