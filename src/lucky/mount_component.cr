module Lucky::MountComponent
  # Appends the `component` to the view.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount MyComponent.new
  # ```
  def mount(component : Lucky::BaseComponent) : Nil
    print_component_comment(component) do
      component.view(view).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount MyComponent.new("jane") do |name|
  #   text name.upcase
  # end
  # ```
  def mount(component : Lucky::BaseComponent) : Nil
    print_component_comment(component) do
      component.view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  private def print_component_comment(component : Lucky::BaseComponent) : Nil
    if Lucky::HTMLPage.settings.render_component_comments
      raw "<!-- BEGIN: #{component.class.name} -->"
      yield
      raw "<!-- END: #{component.class.name} -->"
    else
      yield
    end
  end
end
