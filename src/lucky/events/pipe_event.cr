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

  def before?
    position == Position::Before
  end

  def after?
    position == Position::After
  end
end
