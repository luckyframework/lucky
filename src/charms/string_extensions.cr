class String
  def to_param : String
    self
  end

  # Returns a new string with whitespace and newlines squish to a single space.
  #
  # `String#squish` strips whitespace at the end of the string, and changes
  # consecutive whitespace groups into one space each. For example, it will
  # replace newlines with a single space and convert mutiple spaces to just one
  # space.
  def squish : String
    gsub(/[[:space:]]+/, " ").strip
  end
end
