class Lucky::Events::PipeEvent < Pulsar::Event
  getter :name, :position, :continued

  enum Position
    Before
    After
  end

  def initialize(
    @name : String,
    @position : Position,
    @continued : Bool
  )
  end

  def before? : Bool
    position == Position::Before
  end

  def after? : Bool
    position == Position::After
  end
end
