class String
  def dasherize
    self.gsub("_", "-")
  end

  def humanize
    self.downcase.gsub("_", " ").capitalize
  end
end
