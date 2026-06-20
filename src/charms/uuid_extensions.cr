struct UUID
  include ::Lucky::AllowedInTags

  def to_param : String
    to_s
  end
end
