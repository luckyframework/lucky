module Lucky::CaptureHelpers
  def capture(*args, **named_args, &block)
    buffer = IO::Memory.new
    global_view = @view
    @view = buffer
    yield(*args, **named_args)
    @view = global_view
    buffer.to_s
  end
end