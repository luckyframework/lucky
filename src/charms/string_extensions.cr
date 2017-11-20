require "lucky_inflector"

class String
  def to_param
    self
  end
end
