require "./html_builder"

module Lucky::HTMLPage
  macro included
    include Lucky::HTMLBuilder
    @view = IO::Memory.new
    needs context : HTTP::Server::Context
  end
end
