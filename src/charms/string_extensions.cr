class String
  def dasherize
    self.gsub("_", "-")
  end

  def humanize
    self.downcase.gsub("_", " ").capitalize
  end

  def to_param
    self
  end
end
