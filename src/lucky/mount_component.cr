module Lucky::MountComponent
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
      component.new(*args, **named_args).view(view).context(@context).render
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
      component.new(*args, **named_args).view(view).context(@context).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  # :nodoc:
  def mount(_component : Lucky::BaseComponent, *args, **named_args) : Nil
    {% raise <<-ERROR
        'mount' requires a component class, not an instance of a component.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
        ERROR
    %}
  end

  # :nodoc:
  def mount(_component : Lucky::BaseComponent, *args, **named_args, &) : Nil
    {% raise <<-ERROR
        'mount' requires a component class, not an instance of a component.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
        ERROR
    %}
  end

  # :nodoc:
  def mount_instance(_component : Lucky::BaseComponent.class) : Nil
    {% raise <<-ERROR
        'mount_instance' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
        ERROR
    %}
  end

  # :nodoc:
  def mount_instance(_component : Lucky::BaseComponent.class, &) : Nil
    {% raise <<-ERROR
        'mount_instance' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
        ERROR
    %}
  end

  # Appends the `component` to the view.
  # The `component` is a previously initialized instance of a component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # component = MyComponent.new(name: "Jane")
  # mount_instance(component)
  # ```
  def mount_instance(component : Lucky::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).context(@context).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  # The `component` is a previously initialized instance of a component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # component = MyComponent.new(name: "Jane")
  # mount_instance(component) do |name|
  #   text name.upcase
  # end
  # ```
  def mount_instance(component : Lucky::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).context(@context).render do |*yield_args|
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
