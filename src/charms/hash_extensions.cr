class Hash
  # Return the **nillable** value of a hash key
  #
  # This returns a nillable value stored in a hash. It works with either a
  # String or Symbol as the key. Returns `nil` if the value doesn't exist:
  #
  # ```crystal
  # hash = {"name" => "Karin"}
  # hash.get(:name)  # => "Karin" : (String | Nil)
  # hash.get("name") # => "Karin" : (String | Nil)
  # hash.get(:asdf)  # => nil : (String | Nil)
  # ```
  def get(key : String | Symbol)
    self[key.to_s]?
  end

  # Return the value of a hash key
  #
  # This returns the value stored in a hash. It works with either a String or
  # Symbol as the key. Throws a `KeyError` if the value doesn't exist:
  #
  # ```crystal
  # hash = {"name" => "Karin"}
  # hash.get(:name)  # => "Karin" : String
  # hash.get("name") # => "Karin" : String
  # hash.get(:asdf)  # => KeyError
  # ```
  def get!(key : String | Symbol)
    self[key.to_s]
  end
end
