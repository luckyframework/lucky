class Hash
  # Return the **nillable** value of a hash key
  #
  # This returns the value stored in the hash. Useful for getting values out of
  # the parameter hash. Returns `nil` if the value doesn't exist:
  #
  # ```crystal
  # action do
  #   params.get(:name) # => "Karin" : (String | Nil)
  #   params.get(:asdf) # => nil : (String | Nil)
  # end
  # ```
  def get(key : String | Symbol)
    self[key.to_s]?
  end

  # Return the value of a hash key
  #
  # This returns the value stored in the hash. Useful for getting values out of
  # the parameter hash. Throws a `KeyError` if the value doesn't exist:
  #
  # ```crystal
  # action do
  #   params.get!(:name) # => "Karin" : String
  #   params.get!(:asdf) # => KeyError
  # end
  # ```
  def get!(key : String | Symbol)
    self[key.to_s]
  end
end
