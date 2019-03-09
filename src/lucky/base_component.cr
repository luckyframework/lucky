require "./html_builder"

abstract class Lucky::BaseComponent
  include Lucky::HTMLBuilder

  private def view : IO
    @view || raise "No view was set. Use 'mount' or call 'render_to_string'."
  end

  # :nodoc:
  def view(@view : IO)
    # This is used by Lucky::MountComponent to set the view.
    self
  end

  def render_to_string : String
    String.build do |io|
      view(io)
      render
    end.to_s
  end
end
