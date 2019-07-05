require "../lucky/allowed_in_tags"

struct Int16
  include ::Lucky::AllowedInTags

  def to_param : String
    self.to_s
  end
end
