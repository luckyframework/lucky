abstract class LuckyWeb::Serializer
  def to_json(io)
    render.to_json(io)
  end
end
