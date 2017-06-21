class Hash
  def get(key : String | Symbol)
    self[key.to_s]?
  end

  def get!(key : String | Symbol)
    self[key.to_s]
  end
end
