class Lucky::FallbackRoute
  getter :payload, :params

  def initialize(@payload : Lucky::Action.class, @params = {} of String => String)
  end
end
