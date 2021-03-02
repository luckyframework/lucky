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
end
