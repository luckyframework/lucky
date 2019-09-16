module Lucky::RenderableError
  abstract def http_status : Int32
  abstract def renderable_message : String
end
