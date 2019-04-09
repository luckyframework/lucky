require "./html_builder"

module Lucky::HTMLPage
  Habitat.create do
    setting render_component_comments : Bool = false
  end

  macro included
    include Lucky::HTMLBuilder
    private getter view = IO::Memory.new
    needs context : HTTP::Server::Context
  end
end
