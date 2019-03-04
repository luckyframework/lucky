require "./html_builder"

module Lucky::HTMLPage
  macro included
    include Lucky::HTMLBuilder
    private getter view = IO::Memory.new
    needs context : HTTP::Server::Context
  end
end
