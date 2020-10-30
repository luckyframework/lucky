struct UUID
  include ::Lucky::AllowedInTags

  def to_param : String
    self.to_s
  end
end
