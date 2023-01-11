require "./html_builder"

abstract class Lucky::BaseComponent
  include Lucky::HTMLBuilder

  macro inherited
    # Returns the relative file location to the
    # project root. e.g. src/components/my_component.cr
    def self.file_location
      __FILE__.gsub("#{Dir.current}/", "")
    end
  end

  private def view : IO
    @view || raise "No view was set. Use 'mount' or call 'render_to_string'."
  end

  # :nodoc:
  def view(@view : IO) : self
    # This is used by Lucky::MountComponent to set the view.
    self
  end

  private def context : HTTP::Server::Context
    @context || raise "No context was set in #{self.class.name}. Use 'mount' or set it with 'context(@context)' before rendering."
  end

  def context(@context : HTTP::Server::Context?) : self
    # This is used by Lucky::MountComponent to set the context.
    self
  end

  def render_to_string : String
    String.build do |io|
      view(io)
      render
    end.to_s
  end
end
