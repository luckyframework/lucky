class Lucky::Events::RequestCompleteEvent < Pulsar::Event
  getter duration : Time::Span

  def initialize(@duration : Time::Span)
  end
end
