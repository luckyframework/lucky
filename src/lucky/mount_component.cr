module Lucky::MountComponent
  # Appends the `component` to the view.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # m(MyComponent)
  # m(MyComponent, with_args: 123)
  # ```
  @[Deprecated("Use `#mount` instead. Example: mount(MyComponent, arg1: 123)")]
  def m(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render
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
  # m(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  @[Deprecated("Use `#mount` instead. Example: mount(MyComponent, arg1: 123) do/end")]
  def m(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  # Appends the `component` to the view.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount(MyComponent)
  # mount(MyComponent, with_args: 123)
  # ```
  def mount(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render
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
  # mount(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  def mount(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  private def print_component_comment(component : Lucky::BaseComponent.class) : Nil
    if Lucky::HTMLPage.settings.render_component_comments
      raw "<!-- BEGIN: #{component.name} #{component.file_location} -->"
      yield
      raw "<!-- END: #{component.name} -->"
    else
      yield
    end
  end
end
