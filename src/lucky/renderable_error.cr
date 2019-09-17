module Lucky::RenderableError
  abstract def renderable_status : Int32
  abstract def renderable_message : String
end
