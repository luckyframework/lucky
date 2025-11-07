require "../lucky/tags/allowed_in_tags"

struct Int64
  include ::Lucky::AllowedInTags

  def to_param : String
    self.to_s
  end
end
