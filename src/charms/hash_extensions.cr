class Hash(K, V)
  # Return the **nilable** value of a hash key
  #
  # This returns a value stored in a hash. The key can be specified as a String
  # or Symbol. Internally this works by converting Symbols to Strings. See the
  # code below for an example. It returns `nil` if the value doesn't exist:
  #
  # ```
  # hash = {"name" => "Karin"}
  # hash.get(:name)  # => "Karin" : (String | Nil)
  # hash.get("name") # => "Karin" : (String | Nil)
  # hash.get(:asdf)  # => nil : (String | Nil)
  # ```
  def get(key : String | Symbol) : V?
    self[key.to_s]?
  end

  # Return the value of a hash key
  #
  # This returns a value stored in a hash. The key can be specified as a String
  # or Symbol. Internally this works by converting Symbols to Strings. See the
  # code below for an example. It throws a `KeyError` if the value doesn't
  # exist:
  #
  # ```
  # hash = {"name" => "Karin"}
  # hash.get(:name)  # => "Karin" : String
  # hash.get("name") # => "Karin" : String
  # hash.get(:asdf)  # => KeyError
  # ```
  def get!(key : String | Symbol) : V
    self[key.to_s]
  end
end
