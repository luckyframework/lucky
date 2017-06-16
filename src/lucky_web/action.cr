require "./*"

abstract class LuckyWeb::Action
  getter :context, :path_params

  def initialize(@context : HTTP::Server::Context, @path_params : Hash(String, String))
  end

  abstract def call : LuckyWeb::Response

  EXPOSURES = [] of Symbol

  macro inherited
    include LuckyWeb::Routeable
    include LuckyWeb::Renderable
    include LuckyWeb::ParamParser
  end
end
