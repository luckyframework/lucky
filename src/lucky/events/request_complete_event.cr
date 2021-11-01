class Lucky::Events::RequestCompleteEvent < Pulsar::Event
  getter :duration

  def initialize(@duration : Time::Span)
  end
end
