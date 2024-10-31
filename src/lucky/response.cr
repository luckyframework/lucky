abstract class Lucky::Response
  abstract def print
  abstract def status : Int
  abstract def debug_message : String?
end
